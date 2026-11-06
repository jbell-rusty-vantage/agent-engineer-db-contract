alter table public.research_starter_videos
  add column if not exists pre_research_complete boolean not null default false;

comment on column public.research_starter_videos.pre_research_complete is
  'True only after the Eve pre-research pipeline has been transactionally applied and finalized for this video.';

update public.research_starter_videos as video
set pre_research_complete = true
from public.research_pre_research_video_state as state
where state.video_id = video.video_id
  and state.pre_research_pipeline_finished = true
  and video.pre_research_complete = false;
