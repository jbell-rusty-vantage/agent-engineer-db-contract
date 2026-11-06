-- Jev course-track labels. New values must be committed before rows use them.

alter type public.research_engineering_category_code add value if not exists 'model_behavior';
alter type public.research_engineering_category_code add value if not exists 'inference_serving';
alter type public.research_engineering_category_code add value if not exists 'training_and_post_training';
alter type public.research_engineering_category_code add value if not exists 'data_for_models';
alter type public.research_engineering_category_code add value if not exists 'prompting';
alter type public.research_engineering_category_code add value if not exists 'context_and_memory';
alter type public.research_engineering_category_code add value if not exists 'retrieval_and_search';
alter type public.research_engineering_category_code add value if not exists 'single_agent_loops';
alter type public.research_engineering_category_code add value if not exists 'multi_agent_coordination';
alter type public.research_engineering_category_code add value if not exists 'agent_harnesses';
alter type public.research_engineering_category_code add value if not exists 'tools_and_protocols';
alter type public.research_engineering_category_code add value if not exists 'durable_workflows';
alter type public.research_engineering_category_code add value if not exists 'coding_agents';
alter type public.research_engineering_category_code add value if not exists 'evaluation';
alter type public.research_engineering_category_code add value if not exists 'observability_and_ops';
alter type public.research_engineering_category_code add value if not exists 'security_and_governance';
alter type public.research_engineering_category_code add value if not exists 'voice_and_speech';
alter type public.research_engineering_category_code add value if not exists 'vision_multimodal_robotics';
alter type public.research_engineering_category_code add value if not exists 'product_ux';
alter type public.research_engineering_category_code add value if not exists 'platforms_and_gateways';
alter type public.research_engineering_category_code add value if not exists 'research_automation';
alter type public.research_engineering_category_code add value if not exists 'org_adoption';
alter type public.research_engineering_category_code add value if not exists 'multi_talk_compilation';
alter type public.research_engineering_category_code add value if not exists 'insufficient_evidence';
