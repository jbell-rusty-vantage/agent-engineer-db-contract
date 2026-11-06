begin;

insert into evidence.capture_method (code, description)
values ('https_acquire', 'Trusted exact HTTPS acquisition through an admitted source grant')
on conflict (code) do nothing;

commit;
