-- CRM Devis Bugbusters : structure de la base Supabase (déjà appliquée au projet crm-devis).
-- Référence uniquement : ne contient aucune donnée.

-- Accès réservé au compte équipe (son mot de passe = le code d'accès partagé)
create or replace function public.is_team()
returns boolean language sql stable security invoker set search_path = '' as $$
  select coalesce(auth.jwt() ->> 'email', '') = 'devis.equipe@bugbusters.fr';
$$;

create table public.bpu (
  id text primary key, name text not null, source text not null default '',
  builtin boolean not null default false, ord integer not null default 100,
  items jsonb not null default '[]'::jsonb,
  updated_at timestamptz not null default now(), updated_by text
);

create table public.config (
  key text primary key, data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(), updated_by text
);

create table public.devis (
  id text primary key, num text not null default '', status text not null default 'brouillon',
  do_name text not null default '', client_name text not null default '',
  total_ht numeric(12,2) not null default 0, data jsonb not null,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  updated_by text, deleted_at timestamptz
);

create table public.devis_historique (
  id bigint generated always as identity primary key, devis_id text not null, num text,
  action text not null, auteur text, status text, total_ht numeric(12,2), data jsonb,
  created_at timestamptz not null default now()
);

-- Historique automatique : création, modification (regroupée sur 10 min par auteur),
-- changement de statut, suppression (corbeille) et restauration.
create or replace function public.log_devis()
returns trigger language plpgsql security definer set search_path = '' as $$
declare last_row public.devis_historique%rowtype; act text;
begin
  if tg_op = 'INSERT' then act := 'création';
  elsif new.deleted_at is not null and old.deleted_at is null then act := 'suppression';
  elsif new.deleted_at is null and old.deleted_at is not null then act := 'restauration';
  elsif new.status is distinct from old.status then act := 'statut';
  else act := 'modification'; end if;
  if act = 'modification' then
    select * into last_row from public.devis_historique where devis_id = new.id order by id desc limit 1;
    if found and last_row.action in ('modification', 'création')
       and last_row.auteur is not distinct from new.updated_by
       and last_row.created_at > now() - interval '10 minutes' then
      update public.devis_historique set data = new.data, total_ht = new.total_ht, status = new.status, num = new.num, created_at = now()
        where id = last_row.id;
      return new;
    end if;
  end if;
  insert into public.devis_historique (devis_id, num, action, auteur, status, total_ht, data)
  values (new.id, new.num, act, new.updated_by, new.status, new.total_ht, new.data);
  return new;
end; $$;
create trigger devis_log after insert or update on public.devis for each row execute function public.log_devis();

-- Sécurité : RLS partout, rien pour les visiteurs anonymes, pas de suppression définitive des devis
alter table public.bpu enable row level security;
alter table public.config enable row level security;
alter table public.devis enable row level security;
alter table public.devis_historique enable row level security;
revoke all on public.bpu, public.config, public.devis, public.devis_historique from anon;
create policy bpu_team_all on public.bpu for all to authenticated using ((select public.is_team())) with check ((select public.is_team()));
create policy config_team_all on public.config for all to authenticated using ((select public.is_team())) with check ((select public.is_team()));
create policy devis_team_select on public.devis for select to authenticated using ((select public.is_team()));
create policy devis_team_insert on public.devis for insert to authenticated with check ((select public.is_team()));
create policy devis_team_update on public.devis for update to authenticated using ((select public.is_team())) with check ((select public.is_team()));
create policy historique_team_select on public.devis_historique for select to authenticated using ((select public.is_team()));
revoke delete on public.devis from authenticated;
revoke insert, update, delete on public.devis_historique from authenticated;

alter publication supabase_realtime add table public.devis;
