export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  access: {
    Tables: {
      account_profile: {
        Row: {
          age_band: string
          created_at: string
          eligibility: string
          established_by: string
          jurisdiction: string
          policy_version_id: string
          principal_id: string
          seq: number
          tenant_id: string
        }
        Insert: {
          age_band: string
          created_at?: string
          eligibility: string
          established_by: string
          jurisdiction: string
          policy_version_id: string
          principal_id: string
          seq: number
          tenant_id: string
        }
        Update: {
          age_band?: string
          created_at?: string
          eligibility?: string
          established_by?: string
          jurisdiction?: string
          policy_version_id?: string
          principal_id?: string
          seq?: number
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "account_profile_tenant_id_policy_version_id_fkey"
            columns: ["tenant_id", "policy_version_id"]
            isOneToOne: false
            referencedRelation: "policy_version"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      client_grant: {
        Row: {
          client_kind: string
          created_at: string
          expires_at: string
          id: string
          label: string
          last_used_at: string | null
          principal_id: string
          revoked_at: string | null
          scopes: string[]
          tenant_id: string
          token_sha256: string
          workspace_ids: string[] | null
        }
        Insert: {
          client_kind: string
          created_at?: string
          expires_at: string
          id?: string
          label: string
          last_used_at?: string | null
          principal_id: string
          revoked_at?: string | null
          scopes: string[]
          tenant_id: string
          token_sha256: string
          workspace_ids?: string[] | null
        }
        Update: {
          client_kind?: string
          created_at?: string
          expires_at?: string
          id?: string
          label?: string
          last_used_at?: string | null
          principal_id?: string
          revoked_at?: string | null
          scopes?: string[]
          tenant_id?: string
          token_sha256?: string
          workspace_ids?: string[] | null
        }
        Relationships: []
      }
      guardian_link: {
        Row: {
          consent_evidence_artifact_id: string | null
          consent_method: string | null
          consented_at: string | null
          created_at: string
          guardian_id: string
          help_scope: string[]
          id: string
          revoked_at: string | null
          state: string
          tenant_id: string
          youth_id: string
        }
        Insert: {
          consent_evidence_artifact_id?: string | null
          consent_method?: string | null
          consented_at?: string | null
          created_at?: string
          guardian_id: string
          help_scope?: string[]
          id?: string
          revoked_at?: string | null
          state: string
          tenant_id: string
          youth_id: string
        }
        Update: {
          consent_evidence_artifact_id?: string | null
          consent_method?: string | null
          consented_at?: string | null
          created_at?: string
          guardian_id?: string
          help_scope?: string[]
          id?: string
          revoked_at?: string | null
          state?: string
          tenant_id?: string
          youth_id?: string
        }
        Relationships: []
      }
      policy_version: {
        Row: {
          active_from: string
          approved_by: string | null
          body: Json
          body_sha256: string
          created_at: string
          id: string
          tenant_id: string
          version: number
        }
        Insert: {
          active_from?: string
          approved_by?: string | null
          body: Json
          body_sha256: string
          created_at?: string
          id?: string
          tenant_id: string
          version: number
        }
        Update: {
          active_from?: string
          approved_by?: string | null
          body?: Json
          body_sha256?: string
          created_at?: string
          id?: string
          tenant_id?: string
          version?: number
        }
        Relationships: []
      }
      processing_authorization: {
        Row: {
          basis: string
          granted_at: string
          granted_by: string
          guardian_link_id: string | null
          id: string
          policy_version_id: string
          principal_id: string
          processor_class: string
          processor_key: string
          purpose: string
          tenant_id: string
          withdrawn_at: string | null
        }
        Insert: {
          basis: string
          granted_at?: string
          granted_by: string
          guardian_link_id?: string | null
          id?: string
          policy_version_id: string
          principal_id: string
          processor_class: string
          processor_key: string
          purpose: string
          tenant_id: string
          withdrawn_at?: string | null
        }
        Update: {
          basis?: string
          granted_at?: string
          granted_by?: string
          guardian_link_id?: string | null
          id?: string
          policy_version_id?: string
          principal_id?: string
          processor_class?: string
          processor_key?: string
          purpose?: string
          tenant_id?: string
          withdrawn_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "processing_authorization_tenant_id_guardian_link_id_fkey"
            columns: ["tenant_id", "guardian_link_id"]
            isOneToOne: false
            referencedRelation: "guardian_link"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "processing_authorization_tenant_id_policy_version_id_fkey"
            columns: ["tenant_id", "policy_version_id"]
            isOneToOne: false
            referencedRelation: "policy_version"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      provided_credential: {
        Row: {
          expires_at: string
          id: string
          issued_at: string
          period: string
          principal_id: string
          provider_key: string
          revoked_at: string | null
          secret_handle: string
          spend_limit_usd: number
          tenant_id: string
        }
        Insert: {
          expires_at: string
          id?: string
          issued_at?: string
          period: string
          principal_id: string
          provider_key: string
          revoked_at?: string | null
          secret_handle: string
          spend_limit_usd: number
          tenant_id: string
        }
        Update: {
          expires_at?: string
          id?: string
          issued_at?: string
          period?: string
          principal_id?: string
          provider_key?: string
          revoked_at?: string | null
          secret_handle?: string
          spend_limit_usd?: number
          tenant_id?: string
        }
        Relationships: []
      }
      source_restriction: {
        Row: {
          artifact_id: string | null
          capture_id: string | null
          created_at: string
          decided_by: string | null
          effect: string
          id: string
          kind: string
          lifted_at: string | null
          reason: string
          source_id: string | null
          tenant_id: string
        }
        Insert: {
          artifact_id?: string | null
          capture_id?: string | null
          created_at?: string
          decided_by?: string | null
          effect: string
          id?: string
          kind: string
          lifted_at?: string | null
          reason: string
          source_id?: string | null
          tenant_id: string
        }
        Update: {
          artifact_id?: string | null
          capture_id?: string | null
          created_at?: string
          decided_by?: string | null
          effect?: string
          id?: string
          kind?: string
          lifted_at?: string | null
          reason?: string
          source_id?: string | null
          tenant_id?: string
        }
        Relationships: []
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  acquisition: {
    Tables: {
      attention_policy: {
        Row: {
          budget_credits_per_run: number
          budget_total_usd: number | null
          budget_usd_per_run: number
          cadence: string | null
          channel_entity_ids: string[]
          created_at: string
          decided_by: string
          depth: Json
          designed_in_thread_id: string | null
          id: string
          inquiry_watch_id: string | null
          mission_id: string | null
          rationale: string
          scope_kind: string
          selection: Json
          slug: string
          state: string
          stop_condition: Json
          subject_entity_ids: string[]
          supersedes_id: string | null
          tenant_id: string
          title: string
          triggers: Json
          watch_level: string
        }
        Insert: {
          budget_credits_per_run?: number
          budget_total_usd?: number | null
          budget_usd_per_run?: number
          cadence?: string | null
          channel_entity_ids?: string[]
          created_at?: string
          decided_by: string
          depth?: Json
          designed_in_thread_id?: string | null
          id?: string
          inquiry_watch_id?: string | null
          mission_id?: string | null
          rationale: string
          scope_kind: string
          selection?: Json
          slug: string
          state?: string
          stop_condition?: Json
          subject_entity_ids?: string[]
          supersedes_id?: string | null
          tenant_id?: string
          title: string
          triggers?: Json
          watch_level: string
        }
        Update: {
          budget_credits_per_run?: number
          budget_total_usd?: number | null
          budget_usd_per_run?: number
          cadence?: string | null
          channel_entity_ids?: string[]
          created_at?: string
          decided_by?: string
          depth?: Json
          designed_in_thread_id?: string | null
          id?: string
          inquiry_watch_id?: string | null
          mission_id?: string | null
          rationale?: string
          scope_kind?: string
          selection?: Json
          slug?: string
          state?: string
          stop_condition?: Json
          subject_entity_ids?: string[]
          supersedes_id?: string | null
          tenant_id?: string
          title?: string
          triggers?: Json
          watch_level?: string
        }
        Relationships: [
          {
            foreignKeyName: "attention_policy_supersedes_id_fkey"
            columns: ["supersedes_id"]
            isOneToOne: false
            referencedRelation: "attention_policy"
            referencedColumns: ["id"]
          },
        ]
      }
      attention_sweep: {
        Row: {
          credits: number
          ended_at: string | null
          id: string
          items_captured: number
          items_seen: number
          items_selected: number
          mission_id: string | null
          note: string | null
          origin_kind: string
          outcome: string | null
          policy_id: string
          receipt_id: string | null
          rejected: Json
          spend_usd: number
          started_at: string
          tenant_id: string
          trigger_kind: string
          trigger_ref: Json
          window_from: string | null
          window_to: string | null
        }
        Insert: {
          credits?: number
          ended_at?: string | null
          id?: string
          items_captured?: number
          items_seen?: number
          items_selected?: number
          mission_id?: string | null
          note?: string | null
          origin_kind: string
          outcome?: string | null
          policy_id: string
          receipt_id?: string | null
          rejected?: Json
          spend_usd?: number
          started_at?: string
          tenant_id?: string
          trigger_kind: string
          trigger_ref?: Json
          window_from?: string | null
          window_to?: string | null
        }
        Update: {
          credits?: number
          ended_at?: string | null
          id?: string
          items_captured?: number
          items_seen?: number
          items_selected?: number
          mission_id?: string | null
          note?: string | null
          origin_kind?: string
          outcome?: string | null
          policy_id?: string
          receipt_id?: string | null
          rejected?: Json
          spend_usd?: number
          started_at?: string
          tenant_id?: string
          trigger_kind?: string
          trigger_ref?: Json
          window_from?: string | null
          window_to?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "attention_sweep_policy_id_fkey"
            columns: ["policy_id"]
            isOneToOne: false
            referencedRelation: "attention_policy"
            referencedColumns: ["id"]
          },
        ]
      }
      fetch: {
        Row: {
          actor_principal_id: string | null
          completed_at: string | null
          content_sha256: string | null
          cost_usd: number | null
          credits_used: number | null
          failure_class: string | null
          final_url: string | null
          http_status: number | null
          id: string
          mc_mission_id: string | null
          mc_run_id: string | null
          media_type: string | null
          notes: Json
          origin_kind: string
          origin_label: string
          outcome: string
          prior_capture_id: string | null
          request_url: string
          requested_at: string
          size_bytes: number | null
          sweep_id: string | null
          tenant_id: string
          tool: string
          tool_version: string | null
        }
        Insert: {
          actor_principal_id?: string | null
          completed_at?: string | null
          content_sha256?: string | null
          cost_usd?: number | null
          credits_used?: number | null
          failure_class?: string | null
          final_url?: string | null
          http_status?: number | null
          id?: string
          mc_mission_id?: string | null
          mc_run_id?: string | null
          media_type?: string | null
          notes?: Json
          origin_kind: string
          origin_label: string
          outcome: string
          prior_capture_id?: string | null
          request_url: string
          requested_at?: string
          size_bytes?: number | null
          sweep_id?: string | null
          tenant_id?: string
          tool: string
          tool_version?: string | null
        }
        Update: {
          actor_principal_id?: string | null
          completed_at?: string | null
          content_sha256?: string | null
          cost_usd?: number | null
          credits_used?: number | null
          failure_class?: string | null
          final_url?: string | null
          http_status?: number | null
          id?: string
          mc_mission_id?: string | null
          mc_run_id?: string | null
          media_type?: string | null
          notes?: Json
          origin_kind?: string
          origin_label?: string
          outcome?: string
          prior_capture_id?: string | null
          request_url?: string
          requested_at?: string
          size_bytes?: number | null
          sweep_id?: string | null
          tenant_id?: string
          tool?: string
          tool_version?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "fetch_sweep_id_fkey"
            columns: ["sweep_id"]
            isOneToOne: false
            referencedRelation: "attention_sweep"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  api: {
    Tables: {
      [_ in never]: never
    }
    Views: {
      advisories: {
        Row: {
          advisory: string | null
          advisory_id: string | null
          affected_range: string | null
          claim_id: string | null
          cve_id: string | null
          fixed_version: string | null
          ghsa_id: string | null
          learned_k: number | null
          published_at: string | null
          severity: string | null
          software: string | null
          software_id: string | null
          software_kind: string | null
          summary: string | null
          url: string | null
        }
        Relationships: [
          {
            foreignKeyName: "relationship_from_entity_id_fkey"
            columns: ["software_id"]
            isOneToOne: false
            referencedRelation: "advisories"
            referencedColumns: ["advisory_id"]
          },
          {
            foreignKeyName: "relationship_from_entity_id_fkey"
            columns: ["software_id"]
            isOneToOne: false
            referencedRelation: "agent_skills"
            referencedColumns: ["software_id"]
          },
          {
            foreignKeyName: "relationship_from_entity_id_fkey"
            columns: ["software_id"]
            isOneToOne: false
            referencedRelation: "benchmarks"
            referencedColumns: ["benchmark_id"]
          },
          {
            foreignKeyName: "relationship_from_entity_id_fkey"
            columns: ["software_id"]
            isOneToOne: false
            referencedRelation: "capabilities"
            referencedColumns: ["capability_id"]
          },
          {
            foreignKeyName: "relationship_from_entity_id_fkey"
            columns: ["software_id"]
            isOneToOne: false
            referencedRelation: "compute_devices"
            referencedColumns: ["device_id"]
          },
          {
            foreignKeyName: "relationship_from_entity_id_fkey"
            columns: ["software_id"]
            isOneToOne: false
            referencedRelation: "compute_offerings"
            referencedColumns: ["offering_id"]
          },
          {
            foreignKeyName: "relationship_from_entity_id_fkey"
            columns: ["software_id"]
            isOneToOne: false
            referencedRelation: "concepts"
            referencedColumns: ["concept_id"]
          },
          {
            foreignKeyName: "relationship_from_entity_id_fkey"
            columns: ["software_id"]
            isOneToOne: false
            referencedRelation: "events"
            referencedColumns: ["event_id"]
          },
          {
            foreignKeyName: "relationship_from_entity_id_fkey"
            columns: ["software_id"]
            isOneToOne: false
            referencedRelation: "libraries"
            referencedColumns: ["software_id"]
          },
          {
            foreignKeyName: "relationship_from_entity_id_fkey"
            columns: ["software_id"]
            isOneToOne: false
            referencedRelation: "mcp_servers"
            referencedColumns: ["software_id"]
          },
          {
            foreignKeyName: "relationship_from_entity_id_fkey"
            columns: ["software_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["organization_id"]
          },
          {
            foreignKeyName: "relationship_from_entity_id_fkey"
            columns: ["software_id"]
            isOneToOne: false
            referencedRelation: "people"
            referencedColumns: ["person_id"]
          },
          {
            foreignKeyName: "relationship_from_entity_id_fkey"
            columns: ["software_id"]
            isOneToOne: false
            referencedRelation: "protocol_versions"
            referencedColumns: ["version_id"]
          },
          {
            foreignKeyName: "relationship_from_entity_id_fkey"
            columns: ["software_id"]
            isOneToOne: false
            referencedRelation: "registry_listings"
            referencedColumns: ["server_id"]
          },
          {
            foreignKeyName: "relationship_from_entity_id_fkey"
            columns: ["software_id"]
            isOneToOne: false
            referencedRelation: "repositories"
            referencedColumns: ["software_id"]
          },
          {
            foreignKeyName: "relationship_from_entity_id_fkey"
            columns: ["software_id"]
            isOneToOne: false
            referencedRelation: "software"
            referencedColumns: ["software_id"]
          },
          {
            foreignKeyName: "relationship_from_entity_id_fkey"
            columns: ["software_id"]
            isOneToOne: false
            referencedRelation: "software_releases"
            referencedColumns: ["release_id"]
          },
          {
            foreignKeyName: "relationship_from_entity_id_fkey"
            columns: ["software_id"]
            isOneToOne: false
            referencedRelation: "software_releases"
            referencedColumns: ["software_id"]
          },
          {
            foreignKeyName: "relationship_from_entity_id_fkey"
            columns: ["software_id"]
            isOneToOne: false
            referencedRelation: "source_registry"
            referencedColumns: ["source_entity_id"]
          },
          {
            foreignKeyName: "relationship_from_entity_id_fkey"
            columns: ["software_id"]
            isOneToOne: false
            referencedRelation: "source_registry"
            referencedColumns: ["topic_entity_id"]
          },
          {
            foreignKeyName: "relationship_from_entity_id_fkey"
            columns: ["software_id"]
            isOneToOne: false
            referencedRelation: "talks"
            referencedColumns: ["event_id"]
          },
          {
            foreignKeyName: "relationship_primary_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "claim_candidates"
            referencedColumns: ["claim_id"]
          },
          {
            foreignKeyName: "relationship_primary_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "claim_conflicts"
            referencedColumns: ["first_party_claim_id"]
          },
          {
            foreignKeyName: "relationship_primary_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "claim_conflicts"
            referencedColumns: ["other_claim_id"]
          },
          {
            foreignKeyName: "relationship_primary_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "claim_restatements"
            referencedColumns: ["claim_id"]
          },
          {
            foreignKeyName: "relationship_primary_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "claim_restatements"
            referencedColumns: ["original_claim_id"]
          },
          {
            foreignKeyName: "relationship_primary_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "claim_surfaces"
            referencedColumns: ["claim_id"]
          },
          {
            foreignKeyName: "relationship_primary_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "claim_verdicts"
            referencedColumns: ["claim_id"]
          },
          {
            foreignKeyName: "relationship_primary_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "community_claims"
            referencedColumns: ["claim_id"]
          },
          {
            foreignKeyName: "relationship_primary_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "source_track_record"
            referencedColumns: ["claim_id"]
          },
          {
            foreignKeyName: "relationship_primary_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "verified_claims"
            referencedColumns: ["claim_id"]
          },
        ]
      }
      agent_skills: {
        Row: {
          category: string | null
          concepts: string[] | null
          developers: string[] | null
          docs_url: string | null
          downloads: number | null
          ecosystem: string | null
          kind: string | null
          latest_release: string | null
          latest_release_on: string | null
          license: string | null
          maintainers: string[] | null
          mcp_auth: string | null
          mcp_hosting: string | null
          mcp_is_official: boolean | null
          package_name: string | null
          protocols: string[] | null
          repository_url: string | null
          slug: string | null
          software: string | null
          software_id: string | null
          stars: number | null
          summary: string | null
        }
        Relationships: []
      }
      api_symbols: {
        Row: {
          deprecated: boolean | null
          docs_links: number | null
          docstring_head: string | null
          document_id: string | null
          embedded: boolean | null
          is_public: boolean | null
          lineno: number | null
          module: string | null
          node_id: string | null
          overloads: Json | null
          package: string | null
          path: string | null
          qualified_name: string | null
          release_id: string | null
          release_tag: string | null
          released_on: string | null
          repository: string | null
          signature: string | null
          symbol_kind: string | null
          uses_external: Json | null
        }
        Relationships: []
      }
      attention_policies: {
        Row: {
          budget_credits_per_run: number | null
          budget_usd_per_run: number | null
          cadence: string | null
          channels: string[] | null
          decided_by: string | null
          depth: Json | null
          designed_in_thread_id: string | null
          last_outcome: string | null
          last_seen: number | null
          last_selected: number | null
          last_sweep_at: string | null
          mission: string | null
          policy_id: string | null
          rationale: string | null
          scope_kind: string | null
          selection: Json | null
          slug: string | null
          spend_usd: number | null
          state: string | null
          subjects: string[] | null
          sweeps: number | null
          title: string | null
          triggers: Json | null
          watch_level: string | null
        }
        Relationships: []
      }
      benchmark_scores: {
        Row: {
          belief: string | null
          benchmark: string | null
          benchmark_id: string | null
          benchmark_version: string | null
          benchmark_version_id: string | null
          claim_id: string | null
          conditions: Json | null
          cost_usd: number | null
          harness: string | null
          learned_k: number | null
          n_tasks: number | null
          observed_at: string | null
          reasoning_effort: string | null
          reported_by: string | null
          run_date: string | null
          scope_key: string | null
          score: number | null
          segment_id: string | null
          setting: string | null
          source_kind: string | null
          subject: string | null
          subject_id: string | null
          subject_kind: string | null
          unit: string | null
          valid_from: string | null
        }
        Relationships: [
          {
            foreignKeyName: "segment_primary_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "claim_candidates"
            referencedColumns: ["claim_id"]
          },
          {
            foreignKeyName: "segment_primary_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "claim_conflicts"
            referencedColumns: ["first_party_claim_id"]
          },
          {
            foreignKeyName: "segment_primary_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "claim_conflicts"
            referencedColumns: ["other_claim_id"]
          },
          {
            foreignKeyName: "segment_primary_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "claim_restatements"
            referencedColumns: ["claim_id"]
          },
          {
            foreignKeyName: "segment_primary_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "claim_restatements"
            referencedColumns: ["original_claim_id"]
          },
          {
            foreignKeyName: "segment_primary_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "claim_surfaces"
            referencedColumns: ["claim_id"]
          },
          {
            foreignKeyName: "segment_primary_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "claim_verdicts"
            referencedColumns: ["claim_id"]
          },
          {
            foreignKeyName: "segment_primary_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "community_claims"
            referencedColumns: ["claim_id"]
          },
          {
            foreignKeyName: "segment_primary_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "source_track_record"
            referencedColumns: ["claim_id"]
          },
          {
            foreignKeyName: "segment_primary_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "verified_claims"
            referencedColumns: ["claim_id"]
          },
          {
            foreignKeyName: "segment_ref_entity_id_fkey"
            columns: ["benchmark_version_id"]
            isOneToOne: false
            referencedRelation: "advisories"
            referencedColumns: ["advisory_id"]
          },
          {
            foreignKeyName: "segment_ref_entity_id_fkey"
            columns: ["benchmark_version_id"]
            isOneToOne: false
            referencedRelation: "agent_skills"
            referencedColumns: ["software_id"]
          },
          {
            foreignKeyName: "segment_ref_entity_id_fkey"
            columns: ["benchmark_version_id"]
            isOneToOne: false
            referencedRelation: "benchmarks"
            referencedColumns: ["benchmark_id"]
          },
          {
            foreignKeyName: "segment_ref_entity_id_fkey"
            columns: ["benchmark_version_id"]
            isOneToOne: false
            referencedRelation: "capabilities"
            referencedColumns: ["capability_id"]
          },
          {
            foreignKeyName: "segment_ref_entity_id_fkey"
            columns: ["benchmark_version_id"]
            isOneToOne: false
            referencedRelation: "compute_devices"
            referencedColumns: ["device_id"]
          },
          {
            foreignKeyName: "segment_ref_entity_id_fkey"
            columns: ["benchmark_version_id"]
            isOneToOne: false
            referencedRelation: "compute_offerings"
            referencedColumns: ["offering_id"]
          },
          {
            foreignKeyName: "segment_ref_entity_id_fkey"
            columns: ["benchmark_version_id"]
            isOneToOne: false
            referencedRelation: "concepts"
            referencedColumns: ["concept_id"]
          },
          {
            foreignKeyName: "segment_ref_entity_id_fkey"
            columns: ["benchmark_version_id"]
            isOneToOne: false
            referencedRelation: "events"
            referencedColumns: ["event_id"]
          },
          {
            foreignKeyName: "segment_ref_entity_id_fkey"
            columns: ["benchmark_version_id"]
            isOneToOne: false
            referencedRelation: "libraries"
            referencedColumns: ["software_id"]
          },
          {
            foreignKeyName: "segment_ref_entity_id_fkey"
            columns: ["benchmark_version_id"]
            isOneToOne: false
            referencedRelation: "mcp_servers"
            referencedColumns: ["software_id"]
          },
          {
            foreignKeyName: "segment_ref_entity_id_fkey"
            columns: ["benchmark_version_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["organization_id"]
          },
          {
            foreignKeyName: "segment_ref_entity_id_fkey"
            columns: ["benchmark_version_id"]
            isOneToOne: false
            referencedRelation: "people"
            referencedColumns: ["person_id"]
          },
          {
            foreignKeyName: "segment_ref_entity_id_fkey"
            columns: ["benchmark_version_id"]
            isOneToOne: false
            referencedRelation: "protocol_versions"
            referencedColumns: ["version_id"]
          },
          {
            foreignKeyName: "segment_ref_entity_id_fkey"
            columns: ["benchmark_version_id"]
            isOneToOne: false
            referencedRelation: "registry_listings"
            referencedColumns: ["server_id"]
          },
          {
            foreignKeyName: "segment_ref_entity_id_fkey"
            columns: ["benchmark_version_id"]
            isOneToOne: false
            referencedRelation: "repositories"
            referencedColumns: ["software_id"]
          },
          {
            foreignKeyName: "segment_ref_entity_id_fkey"
            columns: ["benchmark_version_id"]
            isOneToOne: false
            referencedRelation: "software"
            referencedColumns: ["software_id"]
          },
          {
            foreignKeyName: "segment_ref_entity_id_fkey"
            columns: ["benchmark_version_id"]
            isOneToOne: false
            referencedRelation: "software_releases"
            referencedColumns: ["release_id"]
          },
          {
            foreignKeyName: "segment_ref_entity_id_fkey"
            columns: ["benchmark_version_id"]
            isOneToOne: false
            referencedRelation: "software_releases"
            referencedColumns: ["software_id"]
          },
          {
            foreignKeyName: "segment_ref_entity_id_fkey"
            columns: ["benchmark_version_id"]
            isOneToOne: false
            referencedRelation: "source_registry"
            referencedColumns: ["source_entity_id"]
          },
          {
            foreignKeyName: "segment_ref_entity_id_fkey"
            columns: ["benchmark_version_id"]
            isOneToOne: false
            referencedRelation: "source_registry"
            referencedColumns: ["topic_entity_id"]
          },
          {
            foreignKeyName: "segment_ref_entity_id_fkey"
            columns: ["benchmark_version_id"]
            isOneToOne: false
            referencedRelation: "talks"
            referencedColumns: ["event_id"]
          },
          {
            foreignKeyName: "stream_subject_entity_id_fkey"
            columns: ["subject_id"]
            isOneToOne: false
            referencedRelation: "advisories"
            referencedColumns: ["advisory_id"]
          },
          {
            foreignKeyName: "stream_subject_entity_id_fkey"
            columns: ["subject_id"]
            isOneToOne: false
            referencedRelation: "agent_skills"
            referencedColumns: ["software_id"]
          },
          {
            foreignKeyName: "stream_subject_entity_id_fkey"
            columns: ["subject_id"]
            isOneToOne: false
            referencedRelation: "benchmarks"
            referencedColumns: ["benchmark_id"]
          },
          {
            foreignKeyName: "stream_subject_entity_id_fkey"
            columns: ["subject_id"]
            isOneToOne: false
            referencedRelation: "capabilities"
            referencedColumns: ["capability_id"]
          },
          {
            foreignKeyName: "stream_subject_entity_id_fkey"
            columns: ["subject_id"]
            isOneToOne: false
            referencedRelation: "compute_devices"
            referencedColumns: ["device_id"]
          },
          {
            foreignKeyName: "stream_subject_entity_id_fkey"
            columns: ["subject_id"]
            isOneToOne: false
            referencedRelation: "compute_offerings"
            referencedColumns: ["offering_id"]
          },
          {
            foreignKeyName: "stream_subject_entity_id_fkey"
            columns: ["subject_id"]
            isOneToOne: false
            referencedRelation: "concepts"
            referencedColumns: ["concept_id"]
          },
          {
            foreignKeyName: "stream_subject_entity_id_fkey"
            columns: ["subject_id"]
            isOneToOne: false
            referencedRelation: "events"
            referencedColumns: ["event_id"]
          },
          {
            foreignKeyName: "stream_subject_entity_id_fkey"
            columns: ["subject_id"]
            isOneToOne: false
            referencedRelation: "libraries"
            referencedColumns: ["software_id"]
          },
          {
            foreignKeyName: "stream_subject_entity_id_fkey"
            columns: ["subject_id"]
            isOneToOne: false
            referencedRelation: "mcp_servers"
            referencedColumns: ["software_id"]
          },
          {
            foreignKeyName: "stream_subject_entity_id_fkey"
            columns: ["subject_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["organization_id"]
          },
          {
            foreignKeyName: "stream_subject_entity_id_fkey"
            columns: ["subject_id"]
            isOneToOne: false
            referencedRelation: "people"
            referencedColumns: ["person_id"]
          },
          {
            foreignKeyName: "stream_subject_entity_id_fkey"
            columns: ["subject_id"]
            isOneToOne: false
            referencedRelation: "protocol_versions"
            referencedColumns: ["version_id"]
          },
          {
            foreignKeyName: "stream_subject_entity_id_fkey"
            columns: ["subject_id"]
            isOneToOne: false
            referencedRelation: "registry_listings"
            referencedColumns: ["server_id"]
          },
          {
            foreignKeyName: "stream_subject_entity_id_fkey"
            columns: ["subject_id"]
            isOneToOne: false
            referencedRelation: "repositories"
            referencedColumns: ["software_id"]
          },
          {
            foreignKeyName: "stream_subject_entity_id_fkey"
            columns: ["subject_id"]
            isOneToOne: false
            referencedRelation: "software"
            referencedColumns: ["software_id"]
          },
          {
            foreignKeyName: "stream_subject_entity_id_fkey"
            columns: ["subject_id"]
            isOneToOne: false
            referencedRelation: "software_releases"
            referencedColumns: ["release_id"]
          },
          {
            foreignKeyName: "stream_subject_entity_id_fkey"
            columns: ["subject_id"]
            isOneToOne: false
            referencedRelation: "software_releases"
            referencedColumns: ["software_id"]
          },
          {
            foreignKeyName: "stream_subject_entity_id_fkey"
            columns: ["subject_id"]
            isOneToOne: false
            referencedRelation: "source_registry"
            referencedColumns: ["source_entity_id"]
          },
          {
            foreignKeyName: "stream_subject_entity_id_fkey"
            columns: ["subject_id"]
            isOneToOne: false
            referencedRelation: "source_registry"
            referencedColumns: ["topic_entity_id"]
          },
          {
            foreignKeyName: "stream_subject_entity_id_fkey"
            columns: ["subject_id"]
            isOneToOne: false
            referencedRelation: "talks"
            referencedColumns: ["event_id"]
          },
        ]
      }
      benchmarks: {
        Row: {
          agentic: boolean | null
          benchmark: string | null
          benchmark_id: string | null
          canonical_url: string | null
          domain: string | null
          metric: string | null
          organizer: string | null
          reported_by_kinds: string[] | null
          score_count: number | null
          score_type: string | null
          slug: string | null
          versions: string[] | null
        }
        Insert: {
          agentic?: never
          benchmark?: string | null
          benchmark_id?: string | null
          canonical_url?: never
          domain?: never
          metric?: never
          organizer?: never
          reported_by_kinds?: never
          score_count?: never
          score_type?: never
          slug?: string | null
          versions?: never
        }
        Update: {
          agentic?: never
          benchmark?: string | null
          benchmark_id?: string | null
          canonical_url?: never
          domain?: never
          metric?: never
          organizer?: never
          reported_by_kinds?: never
          score_count?: never
          score_type?: never
          slug?: string | null
          versions?: never
        }
        Relationships: []
      }
      bundle_files: {
        Row: {
          capability: string | null
          capability_id: string | null
          commit: string | null
          custody_level: string | null
          document_id: string | null
          executable: boolean | null
          file_role: string | null
          git_blob_id: string | null
          mode: string | null
          node_id: string | null
          path: string | null
          sha256: string | null
          size: number | null
          version_label: string | null
        }
        Relationships: []
      }
      capabilities: {
        Row: {
          bundled_in: string[] | null
          bundles: string[] | null
          capability: string | null
          capability_id: string | null
          commit: string | null
          compatible_with: string[] | null
          custody_level: string | null
          description: string | null
          executable_files: number | null
          files: number | null
          hooks: number | null
          identifiers: Json | null
          kind: string | null
          listed_in: string[] | null
          manifest_document_id: string | null
          repositories: string[] | null
          slug: string | null
          tools: number | null
          version_label: string | null
        }
        Relationships: []
      }
      claim_candidates: {
        Row: {
          agrees_with_first_party_claim: string | null
          attribution: string | null
          claim_id: string | null
          claim_type: string | null
          created_at: string | null
          document_node_id: string | null
          document_title: string | null
          learned_at: string | null
          path: string | null
          source_role: string | null
          speakers: Json | null
          statement: string | null
          status: string | null
          subject_resolved: boolean | null
          subjects: string[] | null
        }
        Insert: {
          agrees_with_first_party_claim?: never
          attribution?: never
          claim_id?: string | null
          claim_type?: string | null
          created_at?: string | null
          document_node_id?: never
          document_title?: never
          learned_at?: never
          path?: never
          source_role?: never
          speakers?: never
          statement?: string | null
          status?: never
          subject_resolved?: never
          subjects?: never
        }
        Update: {
          agrees_with_first_party_claim?: never
          attribution?: never
          claim_id?: string | null
          claim_type?: string | null
          created_at?: string | null
          document_node_id?: never
          document_title?: never
          learned_at?: never
          path?: never
          source_role?: never
          speakers?: never
          statement?: string | null
          status?: never
          subject_resolved?: never
          subjects?: never
        }
        Relationships: []
      }
      claim_conflicts: {
        Row: {
          conflict_id: string | null
          conflict_kind: string | null
          detected_at: string | null
          detected_by: string | null
          first_party_claim_id: string | null
          first_party_statement: string | null
          first_party_status: string | null
          other_claim_id: string | null
          other_provenance: string | null
          other_source_role: string | null
          other_statement: string | null
          other_status: string | null
          reconciliation: string | null
        }
        Relationships: []
      }
      claim_restatements: {
        Row: {
          claim_id: string | null
          created_at: string | null
          dropped: string | null
          original_claim_id: string | null
          original_statement: string | null
          original_status: string | null
          probe: string | null
          qualified: boolean | null
          statement: string | null
          status: string | null
        }
        Relationships: []
      }
      claim_surfaces: {
        Row: {
          assertion_mode: string | null
          claim_id: string | null
          claim_type: string | null
          compared_by: string | null
          conflicts: number | null
          consistency: string | null
          consistency_note: string | null
          deep_link: string | null
          path: string | null
          quote: string | null
          speakers: Json | null
          start_ms: number | null
          statement: string | null
          status: string | null
          subjects: string[] | null
          surfaces: Json | null
          talk: string | null
          talk_id: string | null
        }
        Insert: {
          assertion_mode?: never
          claim_id?: string | null
          claim_type?: string | null
          compared_by?: never
          conflicts?: never
          consistency?: never
          consistency_note?: never
          deep_link?: never
          path?: never
          quote?: never
          speakers?: never
          start_ms?: never
          statement?: string | null
          status?: never
          subjects?: never
          surfaces?: never
          talk?: never
          talk_id?: never
        }
        Update: {
          assertion_mode?: never
          claim_id?: string | null
          claim_type?: string | null
          compared_by?: never
          conflicts?: never
          consistency?: never
          consistency_note?: never
          deep_link?: never
          path?: never
          quote?: never
          speakers?: never
          start_ms?: never
          statement?: string | null
          status?: never
          subjects?: never
          surfaces?: never
          talk?: never
          talk_id?: never
        }
        Relationships: []
      }
      claim_triage: {
        Row: {
          checkability: string | null
          claim_id: string | null
          claim_type: string | null
          components: Json | null
          decided_at: string | null
          decided_by: string | null
          disposition: string | null
          duplicate_of_claim_id: string | null
          priority: number | null
          probe: string | null
          rationale: string | null
          review_state: string | null
          statement: string | null
          status: string | null
          verdict: string | null
        }
        Relationships: [
          {
            foreignKeyName: "claim_triage_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "claim_candidates"
            referencedColumns: ["claim_id"]
          },
          {
            foreignKeyName: "claim_triage_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "claim_conflicts"
            referencedColumns: ["first_party_claim_id"]
          },
          {
            foreignKeyName: "claim_triage_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "claim_conflicts"
            referencedColumns: ["other_claim_id"]
          },
          {
            foreignKeyName: "claim_triage_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "claim_restatements"
            referencedColumns: ["claim_id"]
          },
          {
            foreignKeyName: "claim_triage_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "claim_restatements"
            referencedColumns: ["original_claim_id"]
          },
          {
            foreignKeyName: "claim_triage_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "claim_surfaces"
            referencedColumns: ["claim_id"]
          },
          {
            foreignKeyName: "claim_triage_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "claim_verdicts"
            referencedColumns: ["claim_id"]
          },
          {
            foreignKeyName: "claim_triage_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "community_claims"
            referencedColumns: ["claim_id"]
          },
          {
            foreignKeyName: "claim_triage_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "source_track_record"
            referencedColumns: ["claim_id"]
          },
          {
            foreignKeyName: "claim_triage_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "verified_claims"
            referencedColumns: ["claim_id"]
          },
          {
            foreignKeyName: "claim_triage_duplicate_of_claim_id_fkey"
            columns: ["duplicate_of_claim_id"]
            isOneToOne: false
            referencedRelation: "claim_candidates"
            referencedColumns: ["claim_id"]
          },
          {
            foreignKeyName: "claim_triage_duplicate_of_claim_id_fkey"
            columns: ["duplicate_of_claim_id"]
            isOneToOne: false
            referencedRelation: "claim_conflicts"
            referencedColumns: ["first_party_claim_id"]
          },
          {
            foreignKeyName: "claim_triage_duplicate_of_claim_id_fkey"
            columns: ["duplicate_of_claim_id"]
            isOneToOne: false
            referencedRelation: "claim_conflicts"
            referencedColumns: ["other_claim_id"]
          },
          {
            foreignKeyName: "claim_triage_duplicate_of_claim_id_fkey"
            columns: ["duplicate_of_claim_id"]
            isOneToOne: false
            referencedRelation: "claim_restatements"
            referencedColumns: ["claim_id"]
          },
          {
            foreignKeyName: "claim_triage_duplicate_of_claim_id_fkey"
            columns: ["duplicate_of_claim_id"]
            isOneToOne: false
            referencedRelation: "claim_restatements"
            referencedColumns: ["original_claim_id"]
          },
          {
            foreignKeyName: "claim_triage_duplicate_of_claim_id_fkey"
            columns: ["duplicate_of_claim_id"]
            isOneToOne: false
            referencedRelation: "claim_surfaces"
            referencedColumns: ["claim_id"]
          },
          {
            foreignKeyName: "claim_triage_duplicate_of_claim_id_fkey"
            columns: ["duplicate_of_claim_id"]
            isOneToOne: false
            referencedRelation: "claim_verdicts"
            referencedColumns: ["claim_id"]
          },
          {
            foreignKeyName: "claim_triage_duplicate_of_claim_id_fkey"
            columns: ["duplicate_of_claim_id"]
            isOneToOne: false
            referencedRelation: "community_claims"
            referencedColumns: ["claim_id"]
          },
          {
            foreignKeyName: "claim_triage_duplicate_of_claim_id_fkey"
            columns: ["duplicate_of_claim_id"]
            isOneToOne: false
            referencedRelation: "source_track_record"
            referencedColumns: ["claim_id"]
          },
          {
            foreignKeyName: "claim_triage_duplicate_of_claim_id_fkey"
            columns: ["duplicate_of_claim_id"]
            isOneToOne: false
            referencedRelation: "verified_claims"
            referencedColumns: ["claim_id"]
          },
        ]
      }
      claim_verdicts: {
        Row: {
          cells: Json | null
          channel: string | null
          claim_id: string | null
          claim_type: string | null
          decided_at: string | null
          decided_by: string | null
          probe: string | null
          quote: string | null
          rationale: string | null
          review_state: string | null
          stated_at: string | null
          stated_by: string | null
          statement: string | null
          status: string | null
          verdict: string | null
        }
        Relationships: []
      }
      community_claims: {
        Row: {
          channel: string | null
          channel_slug: string | null
          claim_id: string | null
          claim_type: string | null
          extracted_by: string | null
          quote: string | null
          stated_at: string | null
          stated_by: string | null
          stated_by_kind: string | null
          statement: string | null
          status: string | null
          subjects: string[] | null
          thread: string | null
          thread_state: string | null
          thread_url: string | null
          verdict: string | null
        }
        Relationships: []
      }
      compute_devices: {
        Row: {
          bf16_tflops: number | null
          device: string | null
          device_class: string | null
          device_id: string | null
          form_factor: string | null
          fp4_pflops: number | null
          fp8_tflops: number | null
          interconnect: string | null
          manufacturers: string[] | null
          memory_bandwidth_tbps: number | null
          memory_gb: number | null
          offering_count: number | null
          released_on: string | null
          slug: string | null
          sparse_figures: boolean | null
          spec_url: string | null
          tdp_w: number | null
          vendor: string | null
        }
        Insert: {
          bf16_tflops?: never
          device?: string | null
          device_class?: never
          device_id?: string | null
          form_factor?: never
          fp4_pflops?: never
          fp8_tflops?: never
          interconnect?: never
          manufacturers?: never
          memory_bandwidth_tbps?: never
          memory_gb?: never
          offering_count?: never
          released_on?: never
          slug?: string | null
          sparse_figures?: never
          spec_url?: never
          tdp_w?: never
          vendor?: never
        }
        Update: {
          bf16_tflops?: never
          device?: string | null
          device_class?: never
          device_id?: string | null
          form_factor?: never
          fp4_pflops?: never
          fp8_tflops?: never
          interconnect?: never
          manufacturers?: never
          memory_bandwidth_tbps?: never
          memory_gb?: never
          offering_count?: never
          released_on?: never
          slug?: string | null
          sparse_figures?: never
          spec_url?: never
          tdp_w?: never
          vendor?: never
        }
        Relationships: []
      }
      compute_offerings: {
        Row: {
          amount: number | null
          claim_id: string | null
          commitment: string | null
          currency: string | null
          devices: string[] | null
          gpu_count: number | null
          learned_k: number | null
          memory_gb: number | null
          meter: string | null
          offering: string | null
          offering_class: string | null
          offering_id: string | null
          per: string | null
          pricing_url: string | null
          provider_slug: string | null
          providers: string[] | null
          region: string | null
          slug: string | null
          unit: string | null
          usd_per_gpu_hour: number | null
          valid_from: string | null
          vcpu: number | null
        }
        Relationships: [
          {
            foreignKeyName: "segment_primary_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "claim_candidates"
            referencedColumns: ["claim_id"]
          },
          {
            foreignKeyName: "segment_primary_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "claim_conflicts"
            referencedColumns: ["first_party_claim_id"]
          },
          {
            foreignKeyName: "segment_primary_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "claim_conflicts"
            referencedColumns: ["other_claim_id"]
          },
          {
            foreignKeyName: "segment_primary_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "claim_restatements"
            referencedColumns: ["claim_id"]
          },
          {
            foreignKeyName: "segment_primary_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "claim_restatements"
            referencedColumns: ["original_claim_id"]
          },
          {
            foreignKeyName: "segment_primary_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "claim_surfaces"
            referencedColumns: ["claim_id"]
          },
          {
            foreignKeyName: "segment_primary_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "claim_verdicts"
            referencedColumns: ["claim_id"]
          },
          {
            foreignKeyName: "segment_primary_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "community_claims"
            referencedColumns: ["claim_id"]
          },
          {
            foreignKeyName: "segment_primary_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "source_track_record"
            referencedColumns: ["claim_id"]
          },
          {
            foreignKeyName: "segment_primary_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "verified_claims"
            referencedColumns: ["claim_id"]
          },
        ]
      }
      concepts: {
        Row: {
          component: string | null
          concept: string | null
          concept_id: string | null
          description: string | null
          guidance_items: number | null
          implementations: number | null
          instances: number | null
          kind: string | null
          level: string | null
          modules_covering: number | null
          slug: string | null
          works_about: number | null
        }
        Insert: {
          component?: never
          concept?: string | null
          concept_id?: string | null
          description?: never
          guidance_items?: never
          implementations?: never
          instances?: never
          kind?: string | null
          level?: never
          modules_covering?: never
          slug?: string | null
          works_about?: never
        }
        Update: {
          component?: never
          concept?: string | null
          concept_id?: string | null
          description?: never
          guidance_items?: never
          implementations?: never
          instances?: never
          kind?: string | null
          level?: never
          modules_covering?: never
          slug?: string | null
          works_about?: never
        }
        Relationships: []
      }
      current_facts: {
        Row: {
          amount: number | null
          belief: string | null
          caused_by_event_id: string | null
          correction_reason: string | null
          created_at: string | null
          currency: string | null
          extent_id: string | null
          id: string | null
          k_from: number | null
          k_to: number | null
          payload: Json | null
          primary_claim_id: string | null
          ref_entity_id: string | null
          replaces_segment_id: string | null
          revision_kind: string | null
          scope_key: string | null
          status: string | null
          stream_id: string | null
          stream_kind: string | null
          subject_entity_id: string | null
          subject_relationship_id: string | null
          temporal_basis: string | null
          tenant_id: string | null
          unit: string | null
          valid_during: unknown
        }
        Relationships: []
      }
      current_relationships: {
        Row: {
          created_at: string | null
          episode: number | null
          from_entity_id: string | null
          id: string | null
          k_from: number | null
          k_to: number | null
          kind: string | null
          primary_claim_id: string | null
          properties: Json | null
          qualifier: string | null
          tenant_id: string | null
          to_entity_id: string | null
        }
        Relationships: []
      }
      digest_items: {
        Row: {
          anchor_count: number | null
          claim_id: string | null
          confidence: number | null
          deep_link: string | null
          digest_id: string | null
          document_id: string | null
          document_title: string | null
          document_type_code: string | null
          document_version_id: string | null
          end_ms: number | null
          entity: string | null
          entity_id: string | null
          entity_role: string | null
          item_id: string | null
          item_kind: string | null
          node_ids: string[] | null
          ordinal: number | null
          payload: Json | null
          producer_identity: string | null
          producer_kind: string | null
          scope: string | null
          scope_heading: string | null
          scope_node_id: string | null
          start_ms: number | null
          text: string | null
          unit_change_id: string | null
          version_label: string | null
          work_id: string | null
        }
        Relationships: [
          {
            foreignKeyName: "digest_item_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "claim_candidates"
            referencedColumns: ["claim_id"]
          },
          {
            foreignKeyName: "digest_item_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "claim_conflicts"
            referencedColumns: ["first_party_claim_id"]
          },
          {
            foreignKeyName: "digest_item_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "claim_conflicts"
            referencedColumns: ["other_claim_id"]
          },
          {
            foreignKeyName: "digest_item_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "claim_restatements"
            referencedColumns: ["claim_id"]
          },
          {
            foreignKeyName: "digest_item_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "claim_restatements"
            referencedColumns: ["original_claim_id"]
          },
          {
            foreignKeyName: "digest_item_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "claim_surfaces"
            referencedColumns: ["claim_id"]
          },
          {
            foreignKeyName: "digest_item_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "claim_verdicts"
            referencedColumns: ["claim_id"]
          },
          {
            foreignKeyName: "digest_item_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "community_claims"
            referencedColumns: ["claim_id"]
          },
          {
            foreignKeyName: "digest_item_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "source_track_record"
            referencedColumns: ["claim_id"]
          },
          {
            foreignKeyName: "digest_item_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "verified_claims"
            referencedColumns: ["claim_id"]
          },
          {
            foreignKeyName: "digest_item_entity_id_fkey"
            columns: ["entity_id"]
            isOneToOne: false
            referencedRelation: "advisories"
            referencedColumns: ["advisory_id"]
          },
          {
            foreignKeyName: "digest_item_entity_id_fkey"
            columns: ["entity_id"]
            isOneToOne: false
            referencedRelation: "agent_skills"
            referencedColumns: ["software_id"]
          },
          {
            foreignKeyName: "digest_item_entity_id_fkey"
            columns: ["entity_id"]
            isOneToOne: false
            referencedRelation: "benchmarks"
            referencedColumns: ["benchmark_id"]
          },
          {
            foreignKeyName: "digest_item_entity_id_fkey"
            columns: ["entity_id"]
            isOneToOne: false
            referencedRelation: "capabilities"
            referencedColumns: ["capability_id"]
          },
          {
            foreignKeyName: "digest_item_entity_id_fkey"
            columns: ["entity_id"]
            isOneToOne: false
            referencedRelation: "compute_devices"
            referencedColumns: ["device_id"]
          },
          {
            foreignKeyName: "digest_item_entity_id_fkey"
            columns: ["entity_id"]
            isOneToOne: false
            referencedRelation: "compute_offerings"
            referencedColumns: ["offering_id"]
          },
          {
            foreignKeyName: "digest_item_entity_id_fkey"
            columns: ["entity_id"]
            isOneToOne: false
            referencedRelation: "concepts"
            referencedColumns: ["concept_id"]
          },
          {
            foreignKeyName: "digest_item_entity_id_fkey"
            columns: ["entity_id"]
            isOneToOne: false
            referencedRelation: "events"
            referencedColumns: ["event_id"]
          },
          {
            foreignKeyName: "digest_item_entity_id_fkey"
            columns: ["entity_id"]
            isOneToOne: false
            referencedRelation: "libraries"
            referencedColumns: ["software_id"]
          },
          {
            foreignKeyName: "digest_item_entity_id_fkey"
            columns: ["entity_id"]
            isOneToOne: false
            referencedRelation: "mcp_servers"
            referencedColumns: ["software_id"]
          },
          {
            foreignKeyName: "digest_item_entity_id_fkey"
            columns: ["entity_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["organization_id"]
          },
          {
            foreignKeyName: "digest_item_entity_id_fkey"
            columns: ["entity_id"]
            isOneToOne: false
            referencedRelation: "people"
            referencedColumns: ["person_id"]
          },
          {
            foreignKeyName: "digest_item_entity_id_fkey"
            columns: ["entity_id"]
            isOneToOne: false
            referencedRelation: "protocol_versions"
            referencedColumns: ["version_id"]
          },
          {
            foreignKeyName: "digest_item_entity_id_fkey"
            columns: ["entity_id"]
            isOneToOne: false
            referencedRelation: "registry_listings"
            referencedColumns: ["server_id"]
          },
          {
            foreignKeyName: "digest_item_entity_id_fkey"
            columns: ["entity_id"]
            isOneToOne: false
            referencedRelation: "repositories"
            referencedColumns: ["software_id"]
          },
          {
            foreignKeyName: "digest_item_entity_id_fkey"
            columns: ["entity_id"]
            isOneToOne: false
            referencedRelation: "software"
            referencedColumns: ["software_id"]
          },
          {
            foreignKeyName: "digest_item_entity_id_fkey"
            columns: ["entity_id"]
            isOneToOne: false
            referencedRelation: "software_releases"
            referencedColumns: ["release_id"]
          },
          {
            foreignKeyName: "digest_item_entity_id_fkey"
            columns: ["entity_id"]
            isOneToOne: false
            referencedRelation: "software_releases"
            referencedColumns: ["software_id"]
          },
          {
            foreignKeyName: "digest_item_entity_id_fkey"
            columns: ["entity_id"]
            isOneToOne: false
            referencedRelation: "source_registry"
            referencedColumns: ["source_entity_id"]
          },
          {
            foreignKeyName: "digest_item_entity_id_fkey"
            columns: ["entity_id"]
            isOneToOne: false
            referencedRelation: "source_registry"
            referencedColumns: ["topic_entity_id"]
          },
          {
            foreignKeyName: "digest_item_entity_id_fkey"
            columns: ["entity_id"]
            isOneToOne: false
            referencedRelation: "talks"
            referencedColumns: ["event_id"]
          },
        ]
      }
      endpoints: {
        Row: {
          api_document: string | null
          api_entity_id: string | null
          deprecated: boolean | null
          document_id: string | null
          family: string | null
          logical_key: string | null
          method: string | null
          node_id: string | null
          operation_id: string | null
          parameter_count: number | null
          path: string | null
          published_at: string | null
          summary: string | null
          tags: Json | null
          version_label: string | null
        }
        Relationships: []
      }
      entities: {
        Row: {
          aliases: string[] | null
          created_at: string | null
          created_by_receipt_id: string | null
          display_name: string | null
          id: string | null
          kind: string | null
          lifecycle: string | null
          merged_into_id: string | null
          projection_knowledge_seq: number | null
          slug: string | null
          summary: string | null
          tenant_id: string | null
          updated_at: string | null
        }
        Relationships: []
      }
      events: {
        Row: {
          city: string | null
          country: string | null
          edition_label: string | null
          ends_on: string | null
          event: string | null
          event_id: string | null
          organizers: string[] | null
          series: string[] | null
          slug: string | null
          starts_on: string | null
          talk_count: number | null
          tracks: string[] | null
          website_url: string | null
        }
        Insert: {
          city?: never
          country?: never
          edition_label?: never
          ends_on?: never
          event?: string | null
          event_id?: string | null
          organizers?: never
          series?: never
          slug?: string | null
          starts_on?: never
          talk_count?: never
          tracks?: never
          website_url?: never
        }
        Update: {
          city?: never
          country?: never
          edition_label?: never
          ends_on?: never
          event?: string | null
          event_id?: string | null
          organizers?: never
          series?: never
          slug?: string | null
          starts_on?: never
          talk_count?: never
          tracks?: never
          website_url?: never
        }
        Relationships: []
      }
      events_current: {
        Row: {
          event_id: string | null
          kind: string | null
          object_entity_id: string | null
          occurred_during: unknown
          occurrence_id: string | null
          occurrence_mode: string | null
          payload: Json | null
          subject_entity_id: string | null
          tenant_id: string | null
        }
        Relationships: []
      }
      guidance_items: {
        Row: {
          assurance_level: string | null
          created_at: string | null
          id: string | null
          kind: string | null
          payload: Json | null
          provenance_claim_id: string | null
          scope: Json | null
          statement: string | null
          subject_entity_ids: string[] | null
          tenant_id: string | null
          title: string | null
        }
        Insert: {
          assurance_level?: string | null
          created_at?: string | null
          id?: string | null
          kind?: string | null
          payload?: Json | null
          provenance_claim_id?: string | null
          scope?: Json | null
          statement?: string | null
          subject_entity_ids?: never
          tenant_id?: string | null
          title?: string | null
        }
        Update: {
          assurance_level?: string | null
          created_at?: string | null
          id?: string | null
          kind?: string | null
          payload?: Json | null
          provenance_claim_id?: string | null
          scope?: Json | null
          statement?: string | null
          subject_entity_ids?: never
          tenant_id?: string | null
          title?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "record_provenance_claim_id_fkey"
            columns: ["provenance_claim_id"]
            isOneToOne: false
            referencedRelation: "claim_candidates"
            referencedColumns: ["claim_id"]
          },
          {
            foreignKeyName: "record_provenance_claim_id_fkey"
            columns: ["provenance_claim_id"]
            isOneToOne: false
            referencedRelation: "claim_conflicts"
            referencedColumns: ["first_party_claim_id"]
          },
          {
            foreignKeyName: "record_provenance_claim_id_fkey"
            columns: ["provenance_claim_id"]
            isOneToOne: false
            referencedRelation: "claim_conflicts"
            referencedColumns: ["other_claim_id"]
          },
          {
            foreignKeyName: "record_provenance_claim_id_fkey"
            columns: ["provenance_claim_id"]
            isOneToOne: false
            referencedRelation: "claim_restatements"
            referencedColumns: ["claim_id"]
          },
          {
            foreignKeyName: "record_provenance_claim_id_fkey"
            columns: ["provenance_claim_id"]
            isOneToOne: false
            referencedRelation: "claim_restatements"
            referencedColumns: ["original_claim_id"]
          },
          {
            foreignKeyName: "record_provenance_claim_id_fkey"
            columns: ["provenance_claim_id"]
            isOneToOne: false
            referencedRelation: "claim_surfaces"
            referencedColumns: ["claim_id"]
          },
          {
            foreignKeyName: "record_provenance_claim_id_fkey"
            columns: ["provenance_claim_id"]
            isOneToOne: false
            referencedRelation: "claim_verdicts"
            referencedColumns: ["claim_id"]
          },
          {
            foreignKeyName: "record_provenance_claim_id_fkey"
            columns: ["provenance_claim_id"]
            isOneToOne: false
            referencedRelation: "community_claims"
            referencedColumns: ["claim_id"]
          },
          {
            foreignKeyName: "record_provenance_claim_id_fkey"
            columns: ["provenance_claim_id"]
            isOneToOne: false
            referencedRelation: "source_track_record"
            referencedColumns: ["claim_id"]
          },
          {
            foreignKeyName: "record_provenance_claim_id_fkey"
            columns: ["provenance_claim_id"]
            isOneToOne: false
            referencedRelation: "verified_claims"
            referencedColumns: ["claim_id"]
          },
        ]
      }
      hook_entries: {
        Row: {
          command: string | null
          config_path: string | null
          document_id: string | null
          event: string | null
          hook_type: string | null
          matcher: string | null
          node_id: string | null
          plugin: string | null
          plugin_id: string | null
          version_label: string | null
        }
        Relationships: []
      }
      libraries: {
        Row: {
          category: string | null
          concepts: string[] | null
          developers: string[] | null
          docs_url: string | null
          downloads: number | null
          ecosystem: string | null
          kind: string | null
          latest_release: string | null
          latest_release_on: string | null
          license: string | null
          maintainers: string[] | null
          mcp_auth: string | null
          mcp_hosting: string | null
          mcp_is_official: boolean | null
          package_name: string | null
          protocols: string[] | null
          repository_url: string | null
          slug: string | null
          software: string | null
          software_id: string | null
          stars: number | null
          summary: string | null
        }
        Relationships: []
      }
      mcp_prompts: {
        Row: {
          arguments: Json | null
          description: string | null
          document_id: string | null
          name: string | null
          node_id: string | null
          server: string | null
          server_id: string | null
          version_label: string | null
        }
        Relationships: []
      }
      mcp_resources: {
        Row: {
          description: string | null
          document_id: string | null
          name: string | null
          node_id: string | null
          server: string | null
          server_id: string | null
          uri_template: string | null
          version_label: string | null
        }
        Relationships: []
      }
      mcp_servers: {
        Row: {
          category: string | null
          concepts: string[] | null
          developers: string[] | null
          docs_url: string | null
          downloads: number | null
          ecosystem: string | null
          kind: string | null
          latest_release: string | null
          latest_release_on: string | null
          license: string | null
          maintainers: string[] | null
          mcp_auth: string | null
          mcp_hosting: string | null
          mcp_is_official: boolean | null
          package_name: string | null
          protocols: string[] | null
          repository_url: string | null
          slug: string | null
          software: string | null
          software_id: string | null
          stars: number | null
          summary: string | null
        }
        Relationships: []
      }
      mcp_tools: {
        Row: {
          availability: string | null
          custody_level: string | null
          description: string | null
          document_id: string | null
          document_version_id: string | null
          input_schema: Json | null
          logical_key: string | null
          name: string | null
          node_id: string | null
          required: Json | null
          scopes: Json | null
          server: string | null
          server_id: string | null
          toolset: string | null
          version_label: string | null
        }
        Relationships: []
      }
      mission_progress: {
        Row: {
          budget_cost_usd: number | null
          cost_usd: number | null
          ended_at: string | null
          failed: number | null
          goal: string | null
          mission_id: string | null
          outstanding: number | null
          slug: string | null
          started_at: string | null
          status: Database["orchestration"]["Enums"]["mission_status"] | null
          succeeded: number | null
          work_items: number | null
        }
        Relationships: []
      }
      model_offerings: {
        Row: {
          as_of_knowledge_seq: number | null
          availability: string | null
          batch_input_usd_per_1m: number | null
          cached_input_usd_per_1m: number | null
          input_usd_per_1m: number | null
          model: string | null
          model_version_id: string | null
          offering: string | null
          offering_id: string | null
          offering_key: string | null
          output_usd_per_1m: number | null
          price_claim_id: string | null
          price_locator_id: string | null
          price_observed_at: string | null
          price_valid_from: string | null
          pricing_url: string | null
          provider: string | null
          provider_id: string | null
          region: string | null
          tier: string | null
        }
        Relationships: []
      }
      models: {
        Row: {
          as_of_knowledge_seq: number | null
          availability: string | null
          context_tokens: number | null
          developer: string | null
          developer_id: string | null
          knowledge_cutoff: string | null
          max_output_tokens: number | null
          min_input_usd_per_1m: number | null
          min_output_usd_per_1m: number | null
          modalities: string[] | null
          model: string | null
          model_family: string | null
          model_family_id: string | null
          model_version_id: string | null
          observed_at: string | null
          offering_count: number | null
          open_weights: boolean | null
          provider_model_id: string | null
          reasoning: string | null
          released_on: string | null
          slug: string | null
          structured_output: string | null
          tool_use: string | null
          version_label: string | null
          vision: string | null
        }
        Relationships: []
      }
      organizations: {
        Row: {
          country_code: string | null
          developed_count: number | null
          founded_on: string | null
          headcount: number | null
          offering_count: number | null
          org_kind: string | null
          organization: string | null
          organization_id: string | null
          people_count: number | null
          slug: string | null
          summary: string | null
          website_url: string | null
        }
        Insert: {
          country_code?: never
          developed_count?: never
          founded_on?: never
          headcount?: never
          offering_count?: never
          org_kind?: never
          organization?: string | null
          organization_id?: string | null
          people_count?: never
          slug?: string | null
          summary?: string | null
          website_url?: never
        }
        Update: {
          country_code?: never
          developed_count?: never
          founded_on?: never
          headcount?: never
          offering_count?: never
          org_kind?: never
          organization?: string | null
          organization_id?: string | null
          people_count?: never
          slug?: string | null
          summary?: string | null
          website_url?: never
        }
        Relationships: []
      }
      papers: {
        Row: {
          abstract: string | null
          arxiv_id: string | null
          authors: string[] | null
          canonical_url: string | null
          citations: number | null
          cited_by_count: number | null
          cites_count: number | null
          document_id: string | null
          document_type_code: string | null
          doi: string | null
          ingestion_level: string | null
          paper_id: string | null
          promotion: Json | null
          publication_form: string | null
          published_at: string | null
          publishers: string[] | null
          repositories: string[] | null
          talks_about: number | null
          techniques: string[] | null
          title: string | null
        }
        Relationships: [
          {
            foreignKeyName: "work_id_fkey"
            columns: ["paper_id"]
            isOneToOne: true
            referencedRelation: "advisories"
            referencedColumns: ["advisory_id"]
          },
          {
            foreignKeyName: "work_id_fkey"
            columns: ["paper_id"]
            isOneToOne: true
            referencedRelation: "agent_skills"
            referencedColumns: ["software_id"]
          },
          {
            foreignKeyName: "work_id_fkey"
            columns: ["paper_id"]
            isOneToOne: true
            referencedRelation: "benchmarks"
            referencedColumns: ["benchmark_id"]
          },
          {
            foreignKeyName: "work_id_fkey"
            columns: ["paper_id"]
            isOneToOne: true
            referencedRelation: "capabilities"
            referencedColumns: ["capability_id"]
          },
          {
            foreignKeyName: "work_id_fkey"
            columns: ["paper_id"]
            isOneToOne: true
            referencedRelation: "compute_devices"
            referencedColumns: ["device_id"]
          },
          {
            foreignKeyName: "work_id_fkey"
            columns: ["paper_id"]
            isOneToOne: true
            referencedRelation: "compute_offerings"
            referencedColumns: ["offering_id"]
          },
          {
            foreignKeyName: "work_id_fkey"
            columns: ["paper_id"]
            isOneToOne: true
            referencedRelation: "concepts"
            referencedColumns: ["concept_id"]
          },
          {
            foreignKeyName: "work_id_fkey"
            columns: ["paper_id"]
            isOneToOne: true
            referencedRelation: "events"
            referencedColumns: ["event_id"]
          },
          {
            foreignKeyName: "work_id_fkey"
            columns: ["paper_id"]
            isOneToOne: true
            referencedRelation: "libraries"
            referencedColumns: ["software_id"]
          },
          {
            foreignKeyName: "work_id_fkey"
            columns: ["paper_id"]
            isOneToOne: true
            referencedRelation: "mcp_servers"
            referencedColumns: ["software_id"]
          },
          {
            foreignKeyName: "work_id_fkey"
            columns: ["paper_id"]
            isOneToOne: true
            referencedRelation: "organizations"
            referencedColumns: ["organization_id"]
          },
          {
            foreignKeyName: "work_id_fkey"
            columns: ["paper_id"]
            isOneToOne: true
            referencedRelation: "people"
            referencedColumns: ["person_id"]
          },
          {
            foreignKeyName: "work_id_fkey"
            columns: ["paper_id"]
            isOneToOne: true
            referencedRelation: "protocol_versions"
            referencedColumns: ["version_id"]
          },
          {
            foreignKeyName: "work_id_fkey"
            columns: ["paper_id"]
            isOneToOne: true
            referencedRelation: "registry_listings"
            referencedColumns: ["server_id"]
          },
          {
            foreignKeyName: "work_id_fkey"
            columns: ["paper_id"]
            isOneToOne: true
            referencedRelation: "repositories"
            referencedColumns: ["software_id"]
          },
          {
            foreignKeyName: "work_id_fkey"
            columns: ["paper_id"]
            isOneToOne: true
            referencedRelation: "software"
            referencedColumns: ["software_id"]
          },
          {
            foreignKeyName: "work_id_fkey"
            columns: ["paper_id"]
            isOneToOne: true
            referencedRelation: "software_releases"
            referencedColumns: ["release_id"]
          },
          {
            foreignKeyName: "work_id_fkey"
            columns: ["paper_id"]
            isOneToOne: true
            referencedRelation: "software_releases"
            referencedColumns: ["software_id"]
          },
          {
            foreignKeyName: "work_id_fkey"
            columns: ["paper_id"]
            isOneToOne: true
            referencedRelation: "source_registry"
            referencedColumns: ["source_entity_id"]
          },
          {
            foreignKeyName: "work_id_fkey"
            columns: ["paper_id"]
            isOneToOne: true
            referencedRelation: "source_registry"
            referencedColumns: ["topic_entity_id"]
          },
          {
            foreignKeyName: "work_id_fkey"
            columns: ["paper_id"]
            isOneToOne: true
            referencedRelation: "talks"
            referencedColumns: ["event_id"]
          },
        ]
      }
      people: {
        Row: {
          affiliations: string[] | null
          person: string | null
          person_id: string | null
          profile_url: string | null
          slug: string | null
          talk_count: number | null
          title: string | null
          work_count: number | null
        }
        Insert: {
          affiliations?: never
          person?: string | null
          person_id?: string | null
          profile_url?: never
          slug?: string | null
          talk_count?: never
          title?: never
          work_count?: never
        }
        Update: {
          affiliations?: never
          person?: string | null
          person_id?: string | null
          profile_url?: never
          slug?: string | null
          talk_count?: never
          title?: never
          work_count?: never
        }
        Relationships: []
      }
      probes: {
        Row: {
          claims: number | null
          designed_by: string | null
          designed_in_thread_id: string | null
          hypothesis: string | null
          kind: string | null
          last_run_at: string | null
          matrix: Json | null
          model_policy: string | null
          probe_id: string | null
          runs: number | null
          script_path: string | null
          slug: string | null
          subjects: string[] | null
          title: string | null
          verdicts: Json | null
        }
        Insert: {
          claims?: never
          designed_by?: string | null
          designed_in_thread_id?: string | null
          hypothesis?: string | null
          kind?: string | null
          last_run_at?: never
          matrix?: Json | null
          model_policy?: string | null
          probe_id?: string | null
          runs?: never
          script_path?: string | null
          slug?: string | null
          subjects?: never
          title?: string | null
          verdicts?: never
        }
        Update: {
          claims?: never
          designed_by?: string | null
          designed_in_thread_id?: string | null
          hypothesis?: string | null
          kind?: string | null
          last_run_at?: never
          matrix?: Json | null
          model_policy?: string | null
          probe_id?: string | null
          runs?: never
          script_path?: string | null
          slug?: string | null
          subjects?: never
          title?: string | null
          verdicts?: never
        }
        Relationships: []
      }
      protocol_versions: {
        Row: {
          changelog_url: string | null
          deprecates: Json | null
          highlights: Json | null
          implemented_by: string[] | null
          protocol: string | null
          released_on: string | null
          schema_url: string | null
          status: string | null
          version: string | null
          version_id: string | null
          version_label: string | null
        }
        Relationships: []
      }
      registry_listings: {
        Row: {
          current_status: string | null
          first_party_inferred: boolean | null
          latest_version: string | null
          learned_k: number | null
          namespace: string | null
          properties: Json | null
          registry: string | null
          registry_status: string | null
          relationship_id: string | null
          repository_url: string | null
          server: string | null
          server_id: string | null
          transports: Json | null
        }
        Relationships: []
      }
      repositories: {
        Row: {
          category: string | null
          concepts: string[] | null
          developers: string[] | null
          docs_url: string | null
          downloads: number | null
          ecosystem: string | null
          kind: string | null
          latest_release: string | null
          latest_release_on: string | null
          license: string | null
          maintainers: string[] | null
          mcp_auth: string | null
          mcp_hosting: string | null
          mcp_is_official: boolean | null
          package_name: string | null
          protocols: string[] | null
          repository_url: string | null
          slug: string | null
          software: string | null
          software_id: string | null
          stars: number | null
          summary: string | null
        }
        Relationships: []
      }
      review_queue: {
        Row: {
          assignee: string | null
          candidate_id: string | null
          capability_version_id: string | null
          claim_conflict_id: string | null
          claim_id: string | null
          created_at: string | null
          detail: Json | null
          entity_merge_id: string | null
          id: string | null
          operation_intent_id: string | null
          priority: number | null
          quorum_required: number | null
          state: Database["evaluation"]["Enums"]["review_state"] | null
          subject_kind: string | null
          summary: string | null
          task_kind: string | null
          tenant_id: string | null
          updated_at: string | null
          vector_space_version_id: string | null
        }
        Insert: {
          assignee?: string | null
          candidate_id?: string | null
          capability_version_id?: string | null
          claim_conflict_id?: string | null
          claim_id?: string | null
          created_at?: string | null
          detail?: Json | null
          entity_merge_id?: string | null
          id?: string | null
          operation_intent_id?: string | null
          priority?: number | null
          quorum_required?: number | null
          state?: Database["evaluation"]["Enums"]["review_state"] | null
          subject_kind?: string | null
          summary?: string | null
          task_kind?: string | null
          tenant_id?: string | null
          updated_at?: string | null
          vector_space_version_id?: string | null
        }
        Update: {
          assignee?: string | null
          candidate_id?: string | null
          capability_version_id?: string | null
          claim_conflict_id?: string | null
          claim_id?: string | null
          created_at?: string | null
          detail?: Json | null
          entity_merge_id?: string | null
          id?: string | null
          operation_intent_id?: string | null
          priority?: number | null
          quorum_required?: number | null
          state?: Database["evaluation"]["Enums"]["review_state"] | null
          subject_kind?: string | null
          summary?: string | null
          task_kind?: string | null
          tenant_id?: string | null
          updated_at?: string | null
          vector_space_version_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "review_task_claim_conflict_id_fkey"
            columns: ["claim_conflict_id"]
            isOneToOne: false
            referencedRelation: "claim_conflicts"
            referencedColumns: ["conflict_id"]
          },
          {
            foreignKeyName: "review_task_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "claim_candidates"
            referencedColumns: ["claim_id"]
          },
          {
            foreignKeyName: "review_task_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "claim_conflicts"
            referencedColumns: ["first_party_claim_id"]
          },
          {
            foreignKeyName: "review_task_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "claim_conflicts"
            referencedColumns: ["other_claim_id"]
          },
          {
            foreignKeyName: "review_task_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "claim_restatements"
            referencedColumns: ["claim_id"]
          },
          {
            foreignKeyName: "review_task_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "claim_restatements"
            referencedColumns: ["original_claim_id"]
          },
          {
            foreignKeyName: "review_task_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "claim_surfaces"
            referencedColumns: ["claim_id"]
          },
          {
            foreignKeyName: "review_task_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "claim_verdicts"
            referencedColumns: ["claim_id"]
          },
          {
            foreignKeyName: "review_task_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "community_claims"
            referencedColumns: ["claim_id"]
          },
          {
            foreignKeyName: "review_task_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "source_track_record"
            referencedColumns: ["claim_id"]
          },
          {
            foreignKeyName: "review_task_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "verified_claims"
            referencedColumns: ["claim_id"]
          },
        ]
      }
      software: {
        Row: {
          category: string | null
          concepts: string[] | null
          developers: string[] | null
          docs_url: string | null
          downloads: number | null
          ecosystem: string | null
          kind: string | null
          latest_release: string | null
          latest_release_on: string | null
          license: string | null
          maintainers: string[] | null
          mcp_auth: string | null
          mcp_hosting: string | null
          mcp_is_official: boolean | null
          package_name: string | null
          protocols: string[] | null
          repository_url: string | null
          slug: string | null
          software: string | null
          software_id: string | null
          stars: number | null
          summary: string | null
        }
        Relationships: []
      }
      software_releases: {
        Row: {
          breaking: boolean | null
          highlights: string[] | null
          learned_k: number | null
          observed_at: string | null
          release: string | null
          release_id: string | null
          release_url: string | null
          released_at: string | null
          software: string | null
          software_id: string | null
          software_kind: string | null
          version_label: string | null
        }
        Relationships: []
      }
      source_registry: {
        Row: {
          as_of: string | null
          assessment_id: string | null
          authority_score: number | null
          claims_checked: number | null
          claims_observed: number | null
          confirmed: number | null
          conflict_of_interest: string | null
          current_watch_level: string | null
          median_lead_days: number | null
          method: string | null
          method_disclosure: string | null
          noise_ratio: number | null
          platform: string | null
          qualified: number | null
          rationale: string | null
          recommended_watch_level: string | null
          refuted: number | null
          self_checked: number | null
          source: string | null
          source_entity_id: string | null
          source_kind: string | null
          source_role_code: string | null
          topic: string | null
          topic_entity_id: string | null
          url: string | null
          urls: number | null
        }
        Relationships: []
      }
      source_track_record: {
        Row: {
          claim_id: string | null
          first_party_at: string | null
          probe: string | null
          source: string | null
          source_entity_id: string | null
          source_kind: string | null
          stated_at: string | null
          statement: string | null
          status: string | null
          verdict: string | null
        }
        Relationships: [
          {
            foreignKeyName: "attribution_entity_id_fkey"
            columns: ["source_entity_id"]
            isOneToOne: false
            referencedRelation: "advisories"
            referencedColumns: ["advisory_id"]
          },
          {
            foreignKeyName: "attribution_entity_id_fkey"
            columns: ["source_entity_id"]
            isOneToOne: false
            referencedRelation: "agent_skills"
            referencedColumns: ["software_id"]
          },
          {
            foreignKeyName: "attribution_entity_id_fkey"
            columns: ["source_entity_id"]
            isOneToOne: false
            referencedRelation: "benchmarks"
            referencedColumns: ["benchmark_id"]
          },
          {
            foreignKeyName: "attribution_entity_id_fkey"
            columns: ["source_entity_id"]
            isOneToOne: false
            referencedRelation: "capabilities"
            referencedColumns: ["capability_id"]
          },
          {
            foreignKeyName: "attribution_entity_id_fkey"
            columns: ["source_entity_id"]
            isOneToOne: false
            referencedRelation: "compute_devices"
            referencedColumns: ["device_id"]
          },
          {
            foreignKeyName: "attribution_entity_id_fkey"
            columns: ["source_entity_id"]
            isOneToOne: false
            referencedRelation: "compute_offerings"
            referencedColumns: ["offering_id"]
          },
          {
            foreignKeyName: "attribution_entity_id_fkey"
            columns: ["source_entity_id"]
            isOneToOne: false
            referencedRelation: "concepts"
            referencedColumns: ["concept_id"]
          },
          {
            foreignKeyName: "attribution_entity_id_fkey"
            columns: ["source_entity_id"]
            isOneToOne: false
            referencedRelation: "events"
            referencedColumns: ["event_id"]
          },
          {
            foreignKeyName: "attribution_entity_id_fkey"
            columns: ["source_entity_id"]
            isOneToOne: false
            referencedRelation: "libraries"
            referencedColumns: ["software_id"]
          },
          {
            foreignKeyName: "attribution_entity_id_fkey"
            columns: ["source_entity_id"]
            isOneToOne: false
            referencedRelation: "mcp_servers"
            referencedColumns: ["software_id"]
          },
          {
            foreignKeyName: "attribution_entity_id_fkey"
            columns: ["source_entity_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["organization_id"]
          },
          {
            foreignKeyName: "attribution_entity_id_fkey"
            columns: ["source_entity_id"]
            isOneToOne: false
            referencedRelation: "people"
            referencedColumns: ["person_id"]
          },
          {
            foreignKeyName: "attribution_entity_id_fkey"
            columns: ["source_entity_id"]
            isOneToOne: false
            referencedRelation: "protocol_versions"
            referencedColumns: ["version_id"]
          },
          {
            foreignKeyName: "attribution_entity_id_fkey"
            columns: ["source_entity_id"]
            isOneToOne: false
            referencedRelation: "registry_listings"
            referencedColumns: ["server_id"]
          },
          {
            foreignKeyName: "attribution_entity_id_fkey"
            columns: ["source_entity_id"]
            isOneToOne: false
            referencedRelation: "repositories"
            referencedColumns: ["software_id"]
          },
          {
            foreignKeyName: "attribution_entity_id_fkey"
            columns: ["source_entity_id"]
            isOneToOne: false
            referencedRelation: "software"
            referencedColumns: ["software_id"]
          },
          {
            foreignKeyName: "attribution_entity_id_fkey"
            columns: ["source_entity_id"]
            isOneToOne: false
            referencedRelation: "software_releases"
            referencedColumns: ["release_id"]
          },
          {
            foreignKeyName: "attribution_entity_id_fkey"
            columns: ["source_entity_id"]
            isOneToOne: false
            referencedRelation: "software_releases"
            referencedColumns: ["software_id"]
          },
          {
            foreignKeyName: "attribution_entity_id_fkey"
            columns: ["source_entity_id"]
            isOneToOne: false
            referencedRelation: "source_registry"
            referencedColumns: ["source_entity_id"]
          },
          {
            foreignKeyName: "attribution_entity_id_fkey"
            columns: ["source_entity_id"]
            isOneToOne: false
            referencedRelation: "source_registry"
            referencedColumns: ["topic_entity_id"]
          },
          {
            foreignKeyName: "attribution_entity_id_fkey"
            columns: ["source_entity_id"]
            isOneToOne: false
            referencedRelation: "talks"
            referencedColumns: ["event_id"]
          },
        ]
      }
      symbol_docs: {
        Row: {
          confidence: number | null
          docs_node_id: string | null
          docs_unit_kind: string | null
          document_id: string | null
          document_title: string | null
          document_type_code: string | null
          excerpt: string | null
          heading: string | null
          link_kind: string | null
          link_method: string | null
          package: string | null
          qualified_name: string | null
          release_tag: string | null
          repository: string | null
          section_path: string | null
          symbol_kind: string | null
          symbol_node_id: string | null
          url: string | null
          version_label: string | null
          version_note: string | null
        }
        Relationships: []
      }
      talks: {
        Row: {
          canonical_url: string | null
          document_count: number | null
          duration_ms: number | null
          event: string | null
          event_id: string | null
          event_starts_on: string | null
          level: string | null
          recorded_at: string | null
          repositories: string[] | null
          session_id: string | null
          slides_url: string | null
          slug: string | null
          speaker_affiliations: string[] | null
          speakers: string[] | null
          summary: string | null
          talk_id: string | null
          talk_kind: string | null
          title: string | null
          topics: string[] | null
          track: string | null
          video_url: string | null
        }
        Relationships: [
          {
            foreignKeyName: "work_id_fkey"
            columns: ["talk_id"]
            isOneToOne: true
            referencedRelation: "advisories"
            referencedColumns: ["advisory_id"]
          },
          {
            foreignKeyName: "work_id_fkey"
            columns: ["talk_id"]
            isOneToOne: true
            referencedRelation: "agent_skills"
            referencedColumns: ["software_id"]
          },
          {
            foreignKeyName: "work_id_fkey"
            columns: ["talk_id"]
            isOneToOne: true
            referencedRelation: "benchmarks"
            referencedColumns: ["benchmark_id"]
          },
          {
            foreignKeyName: "work_id_fkey"
            columns: ["talk_id"]
            isOneToOne: true
            referencedRelation: "capabilities"
            referencedColumns: ["capability_id"]
          },
          {
            foreignKeyName: "work_id_fkey"
            columns: ["talk_id"]
            isOneToOne: true
            referencedRelation: "compute_devices"
            referencedColumns: ["device_id"]
          },
          {
            foreignKeyName: "work_id_fkey"
            columns: ["talk_id"]
            isOneToOne: true
            referencedRelation: "compute_offerings"
            referencedColumns: ["offering_id"]
          },
          {
            foreignKeyName: "work_id_fkey"
            columns: ["talk_id"]
            isOneToOne: true
            referencedRelation: "concepts"
            referencedColumns: ["concept_id"]
          },
          {
            foreignKeyName: "work_id_fkey"
            columns: ["talk_id"]
            isOneToOne: true
            referencedRelation: "events"
            referencedColumns: ["event_id"]
          },
          {
            foreignKeyName: "work_id_fkey"
            columns: ["talk_id"]
            isOneToOne: true
            referencedRelation: "libraries"
            referencedColumns: ["software_id"]
          },
          {
            foreignKeyName: "work_id_fkey"
            columns: ["talk_id"]
            isOneToOne: true
            referencedRelation: "mcp_servers"
            referencedColumns: ["software_id"]
          },
          {
            foreignKeyName: "work_id_fkey"
            columns: ["talk_id"]
            isOneToOne: true
            referencedRelation: "organizations"
            referencedColumns: ["organization_id"]
          },
          {
            foreignKeyName: "work_id_fkey"
            columns: ["talk_id"]
            isOneToOne: true
            referencedRelation: "people"
            referencedColumns: ["person_id"]
          },
          {
            foreignKeyName: "work_id_fkey"
            columns: ["talk_id"]
            isOneToOne: true
            referencedRelation: "protocol_versions"
            referencedColumns: ["version_id"]
          },
          {
            foreignKeyName: "work_id_fkey"
            columns: ["talk_id"]
            isOneToOne: true
            referencedRelation: "registry_listings"
            referencedColumns: ["server_id"]
          },
          {
            foreignKeyName: "work_id_fkey"
            columns: ["talk_id"]
            isOneToOne: true
            referencedRelation: "repositories"
            referencedColumns: ["software_id"]
          },
          {
            foreignKeyName: "work_id_fkey"
            columns: ["talk_id"]
            isOneToOne: true
            referencedRelation: "software"
            referencedColumns: ["software_id"]
          },
          {
            foreignKeyName: "work_id_fkey"
            columns: ["talk_id"]
            isOneToOne: true
            referencedRelation: "software_releases"
            referencedColumns: ["release_id"]
          },
          {
            foreignKeyName: "work_id_fkey"
            columns: ["talk_id"]
            isOneToOne: true
            referencedRelation: "software_releases"
            referencedColumns: ["software_id"]
          },
          {
            foreignKeyName: "work_id_fkey"
            columns: ["talk_id"]
            isOneToOne: true
            referencedRelation: "source_registry"
            referencedColumns: ["source_entity_id"]
          },
          {
            foreignKeyName: "work_id_fkey"
            columns: ["talk_id"]
            isOneToOne: true
            referencedRelation: "source_registry"
            referencedColumns: ["topic_entity_id"]
          },
          {
            foreignKeyName: "work_id_fkey"
            columns: ["talk_id"]
            isOneToOne: true
            referencedRelation: "talks"
            referencedColumns: ["event_id"]
          },
        ]
      }
      verified_claims: {
        Row: {
          bound_effect_digest: string | null
          claim_id: string | null
          claim_type: string | null
          effect: Json | null
          executor_version: string | null
          receipt_id: string | null
          statement: string | null
          use_decision_id: string | null
          verdicts: Json | null
          verified_at: string | null
        }
        Relationships: []
      }
      works_authored: {
        Row: {
          covers_concepts: string[] | null
          created_at: string | null
          head_revision_id: string | null
          kind: string | null
          knowledge_seq: number | null
          released: boolean | null
          revision_no: number | null
          runtime_requirements: string[] | null
          slug: string | null
          source_tier: number | null
          title: string | null
          uses_software: string[] | null
          work_id: string | null
          workspace_id: string | null
          workspace_kind: string | null
        }
        Relationships: []
      }
    }
    Functions: {
      advisories_for: {
        Args: { p_software: string; p_version?: string }
        Returns: {
          affected_range: string
          affects_version: boolean
          claim_id: string
          cve_id: string
          fixed_version: string
          ghsa_id: string
          published_at: string
          severity: string
          summary: string
          url: string
        }[]
      }
      attention_due: {
        Args: { p_as_of?: string }
        Returns: {
          budget_usd_per_run: number
          last_sweep_at: string
          mission: string
          policy_id: string
          reason: string
          slug: string
          trigger_ref: Json
          watch_level: string
        }[]
      }
      change_explanation: {
        Args: {
          p_event?: string
          p_include_proposals?: boolean
          p_relationship?: string
          p_segment?: string
        }
        Returns: Json
      }
      changes_since: {
        Args: {
          p_document_types?: string[]
          p_entity_kinds?: string[]
          p_since: string
          p_stream_kinds?: string[]
        }
        Returns: {
          cause_event_id: string
          cause_event_kind: string
          change_kind: string
          change_source: string
          changed_attributes: Json
          claim_id: string
          correction_reason: string
          document_id: string
          document_title: string
          knowledge_seq: number
          learned_at: string
          logical_key: string
          new_value: Json
          old_value: Json
          revision_kind: string
          scope_key: string
          stream_kind: string
          subject: string
          subject_entity_id: string
          unit_kind: string
          world_from: string
        }[]
      }
      cheapest_compute: {
        Args: { p_at?: string; p_commitment?: string; p_device: string }
        Returns: {
          amount: number
          claim_id: string
          commitment: string
          gpu_count: number
          learned_k: number
          locator_count: number
          offering: string
          offering_class: string
          provider: string
          region: string
          unit: string
          usd_per_gpu_hour: number
          valid_from: string
        }[]
      }
      current_event_rows: {
        Args: never
        Returns: {
          event_id: string
          kind: string
          object_entity_id: string
          occurred_during: unknown
          occurrence_id: string
          occurrence_mode: string
          payload: Json
          subject_entity_id: string
          tenant_id: string
        }[]
      }
      current_fact_rows: {
        Args: never
        Returns: {
          amount: number
          belief: string
          caused_by_event_id: string
          correction_reason: string
          created_at: string
          currency: string
          extent_id: string
          id: string
          k_from: number
          k_to: number
          payload: Json
          primary_claim_id: string
          ref_entity_id: string
          replaces_segment_id: string
          revision_kind: string
          scope_key: string
          status: string
          stream_id: string
          stream_kind: string
          subject_entity_id: string
          subject_relationship_id: string
          temporal_basis: string
          tenant_id: string
          unit: string
          valid_during: unknown
        }[]
      }
      current_relationship_rows: {
        Args: never
        Returns: Database["catalog"]["Tables"]["relationship"]["Row"][]
        SetofOptions: {
          from: "*"
          to: "relationship"
          isOneToOne: false
          isSetofReturn: true
        }
      }
      database_release: { Args: never; Returns: Json }
      decide_proposal: {
        Args: {
          p_decided_by?: string
          p_decision: string
          p_note?: string
          p_outcome_claim?: string
          p_proposal: string
        }
        Returns: Json
      }
      digest_item_passages: {
        Args: { p_item: string }
        Returns: {
          deep_link: string
          document_id: string
          end_ms: number
          logical_key: string
          node_id: string
          start_ms: number
          text: string
          unit_kind: string
        }[]
      }
      document_digest: {
        Args: { p_document: string }
        Returns: {
          claim_id: string
          confidence: number
          digest_id: string
          entity: string
          item_kind: string
          node_ids: string[]
          ordinal: number
          payload: Json
          producer_kind: string
          scope: string
          text: string
          version_label: string
        }[]
      }
      document_units: {
        Args: { p_document: string; p_unit_kinds?: string[] }
        Returns: {
          attributes: Json
          end_ms: number
          inline_text: string
          logical_key: string
          node_id: string
          page_number: number
          stable_local_key: string
          start_ms: number
          unit_kind: string
          version_label: string
        }[]
      }
      document_work: { Args: { p_document: string }; Returns: string }
      entity_aliases: { Args: { p_entity: string }; Returns: string[] }
      entity_at: {
        Args: { p_at?: string; p_entity: string; p_k?: number }
        Returns: {
          amount: number
          belief: string
          currency: string
          k_from: number
          k_to: number
          payload: Json
          ref_display_name: string
          ref_entity_id: string
          scope_key: string
          segment_id: string
          status: string
          stream_kind: string
          unit: string
          valid_during: unknown
        }[]
      }
      entity_card: { Args: { p_entity: string }; Returns: Json }
      entity_history: {
        Args: { p_entity: string }
        Returns: {
          details: Json
          item_kind: string
          learned_at: string
          world_from: string
          world_to: string
        }[]
      }
      entity_rows: {
        Args: never
        Returns: Database["catalog"]["Tables"]["entity"]["Row"][]
        SetofOptions: {
          from: "*"
          to: "entity"
          isOneToOne: false
          isSetofReturn: true
        }
      }
      entity_timeline: {
        Args: { p_entity: string; p_from: string; p_k?: number; p_to: string }
        Returns: {
          details: Json
          item_id: string
          item_kind: string
          world_interval: unknown
        }[]
      }
      evidence_packet: { Args: { p_packet: string }; Returns: Json }
      fact_amount: {
        Args: {
          p_at?: string
          p_entity: string
          p_kind: string
          p_scope_key?: string
        }
        Returns: number
      }
      fact_locators: {
        Args: { p_entity: string; p_scope_key?: string; p_stream_kind: string }
        Returns: {
          amount: number
          capture_id: string
          captured_at: string
          claim_id: string
          claim_statement: string
          currency: string
          document_node_id: string
          locator_id: string
          logical_key: string
          normalized_value: string
          payload: Json
          request_url: string
          scope_key: string
          segment_id: string
          selector: Json
          selector_kind: string
          source_url: string
          status: string
          unit: string
          unit_kind: string
          valid_during: unknown
        }[]
      }
      fact_payload: {
        Args: {
          p_at?: string
          p_entity: string
          p_kind: string
          p_scope_key?: string
        }
        Returns: Json
      }
      fact_status: {
        Args: {
          p_at?: string
          p_entity: string
          p_kind: string
          p_scope_key?: string
        }
        Returns: string
      }
      hybrid_knowledge_search_1536: {
        Args: {
          p_as_of?: string
          p_candidate_limit?: number
          p_content_kinds?: string[]
          p_document_types?: string[]
          p_entity_ids?: string[]
          p_filters?: Json
          p_knowledge_seq?: number
          p_min_assurance?: number
          p_publication_id?: string
          p_query_embedding: unknown
          p_query_text: string
          p_result_limit?: number
          p_rrf_k?: number
          p_spaces?: string[]
          p_vector_space_version_id: string
        }
        Returns: {
          channel_scores: Json
          fused_score: number
          search_projection_id: string
          search_text: string
          source_kind: string
          vector_item_id: string
        }[]
      }
      hybrid_knowledge_search_history_1536: {
        Args: {
          p_candidate_limit?: number
          p_entity_ids?: string[]
          p_filters?: Json
          p_knowledge_seq?: number
          p_publication_id?: string
          p_query_embedding: unknown
          p_query_text: string
          p_result_limit?: number
          p_rrf_k?: number
          p_vector_space_version_id: string
          p_world_at?: string
          p_world_from?: string
          p_world_to?: string
        }
        Returns: {
          channel_scores: Json
          fused_score: number
          search_projection_id: string
          search_text: string
          source_kind: string
          vector_item_id: string
        }[]
      }
      interview_outputs: {
        Args: { p_thread: string }
        Returns: {
          last_run_at: string
          output_id: string
          output_kind: string
          runs: number
          slug: string
          state: string
          title: string
        }[]
      }
      knowledge_head: {
        Args: never
        Returns: {
          knowledge_seq: number
          updated_at: string
        }[]
      }
      leaderboard: {
        Args: { p_limit?: number; p_slug: string }
        Returns: {
          display_name: string
          edition_no: number
          entity_id: string
          explanation: Json
          published_at: string
          rank: number
          score: number
          unit: string
        }[]
      }
      leaderboard_diff: {
        Args: { p_edition_a?: number; p_edition_b?: number; p_slug: string }
        Returns: {
          board_date_a: string
          board_date_b: string
          change: string
          conditions: Json
          edition_a: number
          edition_b: number
          entity_id: string
          observed_a: string
          observed_b: string
          rank_a: number
          rank_b: number
          score_a: number
          score_b: number
          subject_label: string
        }[]
      }
      library_dossier: { Args: { p_library: string }; Returns: Json }
      model_offerings_at: {
        Args: { p_at?: string }
        Returns: {
          as_of_knowledge_seq: number
          availability: string
          batch_input_usd_per_1m: number
          cached_input_usd_per_1m: number
          input_usd_per_1m: number
          model: string
          model_version_id: string
          offering: string
          offering_id: string
          offering_key: string
          output_usd_per_1m: number
          price_claim_id: string
          price_locator_id: string
          price_observed_at: string
          price_valid_from: string
          pricing_url: string
          provider: string
          provider_id: string
          region: string
          tier: string
        }[]
      }
      models_at: {
        Args: { p_at?: string }
        Returns: {
          as_of_knowledge_seq: number
          availability: string
          context_tokens: number
          developer: string
          developer_id: string
          knowledge_cutoff: string
          max_output_tokens: number
          min_input_usd_per_1m: number
          min_output_usd_per_1m: number
          modalities: string[]
          model: string
          model_family: string
          model_family_id: string
          model_version_id: string
          observed_at: string
          offering_count: number
          open_weights: boolean
          provider_model_id: string
          reasoning: string
          released_on: string
          slug: string
          structured_output: string
          tool_use: string
          version_label: string
          vision: string
        }[]
      }
      modules_affected_by_release: {
        Args: { p_release: string }
        Returns: {
          binding: string
          breaking: boolean
          release: string
          released_at: string
          revision_created_at: string
          revision_id: string
          revision_title: string
          software: string
          version_spec: string
          work_id: string
          work_kind: string
          work_slug: string
        }[]
      }
      modules_using_software: {
        Args: { p_software: string }
        Returns: {
          binding: string
          latest_release: string
          latest_release_at: string
          latest_release_breaking: boolean
          releases_since_revision: number
          revision_created_at: string
          revision_id: string
          revision_title: string
          software: string
          version_spec: string
          work_id: string
          work_kind: string
          work_slug: string
        }[]
      }
      names: { Args: { p_ids: string[] }; Returns: string[] }
      price_history: {
        Args: { p_meter?: string; p_offering: string }
        Returns: {
          amount: number
          belief: string
          claim_id: string
          currency: string
          k_from: number
          k_to: number
          learned_at: string
          meter: string
          region: string
          replaces_segment_id: string
          retracted_at: string
          segment_id: string
          temporal_basis: string
          tier: string
          unit: string
          valid_during: unknown
        }[]
      }
      price_per_1m: {
        Args: { p_at?: string; p_meter: string; p_offering: string }
        Returns: number
      }
      probe_matrix: {
        Args: { p_probe: string }
        Returns: {
          cell: Json
          cell_label: string
          locator_id: string
          observations: Json
          outcome: string
          resolved: Json
          run_id: string
          started_at: string
        }[]
      }
      probe_revalidation_due: {
        Args: { p_as_of?: string }
        Returns: {
          cell_label: string
          last_run_at: string
          library: string
          newest_released_at: string
          newest_version: string
          probe: string
          probe_id: string
          reason: string
          resolved_version: string
        }[]
      }
      product_command: {
        Args: {
          p_expected_head: string
          p_idempotency_key: string
          p_operation: string
          p_payload: Json
          p_workspace_id: string
        }
        Returns: Json
      }
      product_read: {
        Args: { p_operation: string; p_payload: Json; p_workspace_id: string }
        Returns: Json
      }
      product_scope: { Args: { p_scope: string }; Returns: Json }
      product_worker: {
        Args: { p_operation: string; p_payload: Json }
        Returns: Json
      }
      proposals: {
        Args: {
          p_entity?: string
          p_event?: string
          p_relationship?: string
          p_review_states?: string[]
          p_segment?: string
        }
        Returns: {
          authored_by: string
          authored_by_kind: string
          basis: Json
          cause_event_id: string
          confidence: string
          created_at: string
          label: string
          object: string
          object_entity_id: string
          outcome_claim_id: string
          proposal_id: string
          proposal_kind: string
          publication: string
          rationale: string
          relationship_kind: string
          review_state: string
          statement: string
          subject: string
          subject_entity_id: string
          target: Json
        }[]
      }
      propose: {
        Args: {
          p_actor?: Json
          p_basis?: Json
          p_cause_event?: string
          p_confidence: string
          p_idempotency_key: string
          p_kind: string
          p_label?: string
          p_object?: string
          p_rationale: string
          p_relationship_kind?: string
          p_statement: string
          p_subject?: string
          p_target?: Json
          p_world_during?: unknown
        }
        Returns: Json
      }
      propose_verdict: {
        Args: {
          p_actor?: Json
          p_cells: Json
          p_claim_id: string
          p_idempotency_key: string
          p_probe_id: string
          p_rationale: string
          p_verdict: string
        }
        Returns: Json
      }
      publish_proposal: {
        Args: {
          p_proposal: string
          p_publish?: boolean
          p_published_by?: string
        }
        Returns: Json
      }
      raise_attention_sweep: {
        Args: {
          p_actor?: Json
          p_idempotency_key: string
          p_note?: string
          p_policy: string
          p_trigger_kind: string
          p_trigger_ref?: Json
          p_window_from?: string
          p_window_to?: string
        }
        Returns: Json
      }
      record_claim: {
        Args: {
          p_actor?: Json
          p_attributions?: Json
          p_claim_type: string
          p_evidence: Json
          p_idempotency_key: string
          p_statement: string
          p_structured?: Json
          p_subjects?: Json
        }
        Returns: Json
      }
      record_probe_run: {
        Args: {
          p_actor?: Json
          p_cell?: Json
          p_cell_label: string
          p_idempotency_key: string
          p_observations?: Json
          p_outcome: string
          p_output?: Json
          p_probe_id: string
          p_resolved?: Json
          p_run?: Json
          p_started_at: string
          p_sweep_id?: string
        }
        Returns: Json
      }
      record_source_assessment: {
        Args: {
          p_actor?: Json
          p_conflict_of_interest?: string
          p_idempotency_key: string
          p_method: string
          p_method_disclosure?: string
          p_rationale?: string
          p_source_role_code?: string
          p_subject_entity_id: string
          p_topic_entity_id?: string
        }
        Returns: Json
      }
      record_triage: {
        Args: {
          p_actor?: Json
          p_checkability: string
          p_claim_id: string
          p_components?: Json
          p_disposition: string
          p_duplicate_of_claim_id?: string
          p_idempotency_key: string
          p_priority?: number
          p_probe_id?: string
          p_rationale: string
        }
        Returns: Json
      }
      register_probe: {
        Args: {
          p_actor?: Json
          p_budget_usd?: number
          p_claims: Json
          p_environment?: Json
          p_hypothesis: string
          p_idempotency_key: string
          p_kind: string
          p_matrix?: Json
          p_model_policy?: string
          p_script?: Json
          p_slug: string
          p_subject_entity_ids?: string[]
          p_title: string
        }
        Returns: Json
      }
      related: {
        Args: {
          p_at?: string
          p_direction?: string
          p_entity: string
          p_kind: string
        }
        Returns: string[]
      }
      relationships: {
        Args: {
          p_at?: string
          p_direction?: string
          p_entity: string
          p_k?: number
          p_kind?: string
        }
        Returns: Database["catalog"]["Tables"]["relationship"]["Row"][]
        SetofOptions: {
          from: "*"
          to: "relationship"
          isOneToOne: false
          isSetofReturn: true
        }
      }
      release_digest: {
        Args: { p_release: string }
        Returns: {
          change_items: Json
          document_id: string
          item_id: string
          item_kind: string
          ordinal: number
          symbols: Json
          text: string
        }[]
      }
      release_order: { Args: { p_tag: string }; Returns: number[] }
      releases_needing_review: {
        Args: never
        Returns: {
          claim_id: string
          decided_at: string
          release_id: string
          release_no: number
          released_at: string
          root_work_id: string
          statement: string
          status_now: string
          verdict_at_release: string
          verdict_now: string
        }[]
      }
      resolve_entity: {
        Args: { p_text: string }
        Returns: {
          display_name: string
          entity_id: string
          kind: string
          score: number
        }[]
      }
      restate_claim: {
        Args: {
          p_actor?: Json
          p_dropped?: string
          p_idempotency_key: string
          p_original_claim_id: string
          p_polarity?: Json
          p_qualified?: boolean
          p_statement: string
        }
        Returns: Json
      }
      search_knowledge: {
        Args: {
          p_as_of?: string
          p_candidate_limit?: number
          p_collapse?: boolean
          p_content_kinds?: string[]
          p_document_types?: string[]
          p_entity_ids?: string[]
          p_evidence_weight?: number
          p_lenses?: string[]
          p_limit?: number
          p_query: string
          p_query_embedding?: unknown
          p_rrf_k?: number
          p_source_roles?: string[]
          p_space_slugs?: string[]
          p_tiers?: number[]
          p_unit_kinds?: string[]
        }
        Returns: {
          channel_scores: Json
          content_kind: string
          document_id: string
          document_type_code: string
          document_version_id: string
          end_ms: number
          entity_id: string
          fused_score: number
          lens: string
          observed_at: string
          snippet: string
          source_tier: number
          space_slug: string
          start_ms: number
          target_id: string
          target_kind: string
          unit_kind: string
          valid_during: unknown
          vector_item_id: string
          workspace_id: string
        }[]
      }
      search_knowledge_1536: {
        Args: {
          p_limit?: number
          p_query: unknown
          p_vector_space_version_id: string
        }
        Returns: {
          score: number
          search_projection_id: string
          search_text: string
          vector_item_id: string
        }[]
      }
      search_unified: {
        Args: {
          p_as_of?: string
          p_candidate_limit?: number
          p_collapse?: boolean
          p_content_kinds?: string[]
          p_document_types?: string[]
          p_entity_ids?: string[]
          p_evidence_weight?: number
          p_lenses?: string[]
          p_limit?: number
          p_query: string
          p_query_embedding?: unknown
          p_rrf_k?: number
          p_source_roles?: string[]
          p_space_slugs?: string[]
          p_tiers?: number[]
          p_unit_kinds?: string[]
          p_workspace_ids?: string[]
        }
        Returns: {
          channel_scores: Json
          content_kind: string
          document_id: string
          document_type_code: string
          document_version_id: string
          end_ms: number
          entity_id: string
          fused_score: number
          lens: string
          observed_at: string
          snippet: string
          source_tier: number
          space_slug: string
          start_ms: number
          target_id: string
          target_kind: string
          unit_kind: string
          valid_during: unknown
          vector_item_id: string
          workspace_id: string
        }[]
      }
      settle_attention_sweep: {
        Args: {
          p_actor?: Json
          p_credits?: number
          p_idempotency_key: string
          p_items_captured: number
          p_items_seen: number
          p_items_selected: number
          p_outcome: string
          p_rejected?: Json
          p_spend_usd?: number
          p_sweep_id: string
        }
        Returns: Json
      }
      submit_intent: {
        Args: {
          p_attempt_id?: string
          p_idempotency_key: string
          p_intent_type: string
          p_mission_id?: string
          p_payload: Json
          p_preconditions?: Json
        }
        Returns: string
      }
      summary_evidence: {
        Args: { p_summary: string }
        Returns: {
          chunk_id: string
          end_ms: number
          locator_id: string
          node_id: string
          start_ms: number
        }[]
      }
      symbol_changes: {
        Args: { p_from_tag: string; p_repository: string; p_to_tag: string }
        Returns: {
          change: string
          from_node_id: string
          module: string
          qualified_name: string
          signature_from: string
          signature_to: string
          symbol_kind: string
          to_node_id: string
        }[]
      }
      symbol_history: {
        Args: { p_package?: string; p_repository: string }
        Returns: {
          first_released_on: string
          first_tag: string
          in_latest: boolean
          last_tag: string
          latest_node_id: string
          package: string
          qualified_name: string
          releases_present: number
          releases_total: number
          symbol_kind: string
        }[]
      }
      talk_segments: {
        Args: {
          p_from_ms?: number
          p_query?: string
          p_talk: string
          p_to_ms?: number
        }
        Returns: {
          deep_link: string
          document_id: string
          end_ms: number
          logical_key: string
          node_id: string
          representation_id: string
          slide_n: number
          start_ms: number
          text: string
          unit_kind: string
        }[]
      }
      talks_about: {
        Args: { p_entity: string }
        Returns: {
          deep_link: string
          document_id: string
          end_ms: number
          entity_role: string
          item_id: string
          item_kind: string
          level: string
          node_id: string
          start_ms: number
          talk: string
          talk_id: string
          text: string
        }[]
      }
      timecode_link: {
        Args: { p_start_ms: number; p_url: string }
        Returns: string
      }
      unit_entities: {
        Args: { p_node: string }
        Returns: {
          confidence: number
          entity: string
          entity_id: string
          entity_kind: string
          method: string
          role: string
        }[]
      }
      what_changed: {
        Args: { p_entity: string; p_k1: number; p_k2: number }
        Returns: {
          change_kind: string
          details: Json
          item_id: string
          item_kind: string
          knowledge_seq: number
        }[]
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  authoring: {
    Tables: {
      asset_scope: {
        Row: {
          artifact_id: string
          created_at: string
          expires_at: string | null
          id: string
          registered_by: string
          retention: string
          revoked_at: string | null
          rights_basis: string
          tenant_id: string
          usage: string
          workspace_id: string
        }
        Insert: {
          artifact_id: string
          created_at?: string
          expires_at?: string | null
          id?: string
          registered_by: string
          retention?: string
          revoked_at?: string | null
          rights_basis: string
          tenant_id: string
          usage: string
          workspace_id: string
        }
        Update: {
          artifact_id?: string
          created_at?: string
          expires_at?: string | null
          id?: string
          registered_by?: string
          retention?: string
          revoked_at?: string | null
          rights_basis?: string
          tenant_id?: string
          usage?: string
          workspace_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "asset_scope_tenant_id_workspace_id_fkey"
            columns: ["tenant_id", "workspace_id"]
            isOneToOne: false
            referencedRelation: "workspace"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      block_type: {
        Row: {
          allowed_roles: string[]
          code: string
          description: string
          needs_fallback: boolean
          required_roles: string[]
          tier: number
        }
        Insert: {
          allowed_roles?: string[]
          code: string
          description: string
          needs_fallback: boolean
          required_roles?: string[]
          tier: number
        }
        Update: {
          allowed_roles?: string[]
          code?: string
          description?: string
          needs_fallback?: boolean
          required_roles?: string[]
          tier?: number
        }
        Relationships: []
      }
      command: {
        Row: {
          actor_id: string
          client_grant_id: string | null
          created_at: string
          id: string
          idempotency_key: string
          input_sha256: string
          operation: string
          origin: string
          origin_ref: Json
          result: Json
          tenant_id: string
          workspace_id: string
        }
        Insert: {
          actor_id: string
          client_grant_id?: string | null
          created_at?: string
          id?: string
          idempotency_key: string
          input_sha256: string
          operation: string
          origin: string
          origin_ref?: Json
          result: Json
          tenant_id: string
          workspace_id: string
        }
        Update: {
          actor_id?: string
          client_grant_id?: string | null
          created_at?: string
          id?: string
          idempotency_key?: string
          input_sha256?: string
          operation?: string
          origin?: string
          origin_ref?: Json
          result?: Json
          tenant_id?: string
          workspace_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "command_tenant_id_workspace_id_fkey"
            columns: ["tenant_id", "workspace_id"]
            isOneToOne: false
            referencedRelation: "workspace"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      deployment: {
        Row: {
          created_at: string
          created_by: string
          environment: string
          external_ref: Json | null
          file_set_id: string | null
          id: string
          origin: string
          retired_at: string | null
          revision_id: string | null
          snapshot_file_set_id: string | null
          status: string
          target: string
          tenant_id: string
          url: string
          workspace_id: string
        }
        Insert: {
          created_at?: string
          created_by: string
          environment: string
          external_ref?: Json | null
          file_set_id?: string | null
          id?: string
          origin: string
          retired_at?: string | null
          revision_id?: string | null
          snapshot_file_set_id?: string | null
          status: string
          target: string
          tenant_id: string
          url: string
          workspace_id: string
        }
        Update: {
          created_at?: string
          created_by?: string
          environment?: string
          external_ref?: Json | null
          file_set_id?: string | null
          id?: string
          origin?: string
          retired_at?: string | null
          revision_id?: string | null
          snapshot_file_set_id?: string | null
          status?: string
          target?: string
          tenant_id?: string
          url?: string
          workspace_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "deployment_tenant_id_workspace_id_file_set_id_fkey"
            columns: ["tenant_id", "workspace_id", "file_set_id"]
            isOneToOne: false
            referencedRelation: "file_set"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
          {
            foreignKeyName: "deployment_tenant_id_workspace_id_revision_id_fkey"
            columns: ["tenant_id", "workspace_id", "revision_id"]
            isOneToOne: false
            referencedRelation: "work_revision"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
          {
            foreignKeyName: "deployment_tenant_id_workspace_id_snapshot_file_set_id_fkey"
            columns: ["tenant_id", "workspace_id", "snapshot_file_set_id"]
            isOneToOne: false
            referencedRelation: "file_set"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
        ]
      }
      distribution: {
        Row: {
          channel: string
          closed_at: string | null
          closed_event_id: string | null
          created_at: string
          created_by: string
          id: string
          root_work_id: string
          tenant_id: string
          title: string
          workspace_id: string
        }
        Insert: {
          channel: string
          closed_at?: string | null
          closed_event_id?: string | null
          created_at?: string
          created_by: string
          id?: string
          root_work_id: string
          tenant_id: string
          title: string
          workspace_id: string
        }
        Update: {
          channel?: string
          closed_at?: string | null
          closed_event_id?: string | null
          created_at?: string
          created_by?: string
          id?: string
          root_work_id?: string
          tenant_id?: string
          title?: string
          workspace_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "distribution_tenant_id_workspace_id_closed_event_id_fkey"
            columns: ["tenant_id", "workspace_id", "closed_event_id"]
            isOneToOne: false
            referencedRelation: "event"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
          {
            foreignKeyName: "distribution_tenant_id_workspace_id_root_work_id_fkey"
            columns: ["tenant_id", "workspace_id", "root_work_id"]
            isOneToOne: false
            referencedRelation: "work"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
        ]
      }
      distribution_member: {
        Row: {
          created_at: string
          distribution_id: string
          grant_basis: string
          granted_by: string
          id: string
          principal_id: string
          revoked_at: string | null
          tenant_id: string
          workspace_id: string
        }
        Insert: {
          created_at?: string
          distribution_id: string
          grant_basis: string
          granted_by: string
          id?: string
          principal_id: string
          revoked_at?: string | null
          tenant_id: string
          workspace_id: string
        }
        Update: {
          created_at?: string
          distribution_id?: string
          grant_basis?: string
          granted_by?: string
          id?: string
          principal_id?: string
          revoked_at?: string | null
          tenant_id?: string
          workspace_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "distribution_member_tenant_id_workspace_id_distribution_id_fkey"
            columns: ["tenant_id", "workspace_id", "distribution_id"]
            isOneToOne: false
            referencedRelation: "distribution"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
        ]
      }
      distribution_offer: {
        Row: {
          approval_event_id: string
          created_at: string
          distribution_id: string
          end_event_id: string | null
          end_kind: string | null
          ended_at: string | null
          id: string
          offer_no: number
          offered_by: string
          release_id: string
          tenant_id: string
          terms: Json
          terms_schema: string
          workspace_id: string
        }
        Insert: {
          approval_event_id: string
          created_at?: string
          distribution_id: string
          end_event_id?: string | null
          end_kind?: string | null
          ended_at?: string | null
          id?: string
          offer_no: number
          offered_by: string
          release_id: string
          tenant_id: string
          terms: Json
          terms_schema: string
          workspace_id: string
        }
        Update: {
          approval_event_id?: string
          created_at?: string
          distribution_id?: string
          end_event_id?: string | null
          end_kind?: string | null
          ended_at?: string | null
          id?: string
          offer_no?: number
          offered_by?: string
          release_id?: string
          tenant_id?: string
          terms?: Json
          terms_schema?: string
          workspace_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "distribution_offer_tenant_id_workspace_id_approval_event_i_fkey"
            columns: ["tenant_id", "workspace_id", "approval_event_id"]
            isOneToOne: false
            referencedRelation: "event"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
          {
            foreignKeyName: "distribution_offer_tenant_id_workspace_id_distribution_id_fkey"
            columns: ["tenant_id", "workspace_id", "distribution_id"]
            isOneToOne: false
            referencedRelation: "distribution"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
          {
            foreignKeyName: "distribution_offer_tenant_id_workspace_id_end_event_id_fkey"
            columns: ["tenant_id", "workspace_id", "end_event_id"]
            isOneToOne: false
            referencedRelation: "event"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
          {
            foreignKeyName: "distribution_offer_tenant_id_workspace_id_release_id_fkey"
            columns: ["tenant_id", "workspace_id", "release_id"]
            isOneToOne: false
            referencedRelation: "release"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
        ]
      }
      event: {
        Row: {
          actor_id: string
          actor_kind: string
          author_role: string
          client_surface: string
          created_at: string
          dedupe_key: string
          id: string
          kind: string
          payload: Json
          payload_schema: string
          related_event_id: string | null
          revision_id: string | null
          tenant_id: string
          work_id: string | null
          workspace_id: string
        }
        Insert: {
          actor_id: string
          actor_kind: string
          author_role: string
          client_surface: string
          created_at?: string
          dedupe_key: string
          id?: string
          kind: string
          payload?: Json
          payload_schema: string
          related_event_id?: string | null
          revision_id?: string | null
          tenant_id: string
          work_id?: string | null
          workspace_id: string
        }
        Update: {
          actor_id?: string
          actor_kind?: string
          author_role?: string
          client_surface?: string
          created_at?: string
          dedupe_key?: string
          id?: string
          kind?: string
          payload?: Json
          payload_schema?: string
          related_event_id?: string | null
          revision_id?: string | null
          tenant_id?: string
          work_id?: string | null
          workspace_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "event_tenant_id_workspace_id_fkey"
            columns: ["tenant_id", "workspace_id"]
            isOneToOne: false
            referencedRelation: "workspace"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "event_tenant_id_workspace_id_related_event_id_fkey"
            columns: ["tenant_id", "workspace_id", "related_event_id"]
            isOneToOne: false
            referencedRelation: "event"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
          {
            foreignKeyName: "event_tenant_id_workspace_id_work_id_fkey"
            columns: ["tenant_id", "workspace_id", "work_id"]
            isOneToOne: false
            referencedRelation: "work"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
          {
            foreignKeyName: "event_tenant_id_workspace_id_work_id_revision_id_fkey"
            columns: ["tenant_id", "workspace_id", "work_id", "revision_id"]
            isOneToOne: false
            referencedRelation: "work_revision"
            referencedColumns: ["tenant_id", "workspace_id", "work_id", "id"]
          },
        ]
      }
      file_set: {
        Row: {
          created_at: string
          created_by: string
          entrypoint: string
          file_count: number
          id: string
          origin: string
          tenant_id: string
          total_bytes: number
          tree_sha256: string
          workspace_id: string
        }
        Insert: {
          created_at?: string
          created_by: string
          entrypoint: string
          file_count: number
          id?: string
          origin: string
          tenant_id: string
          total_bytes: number
          tree_sha256: string
          workspace_id: string
        }
        Update: {
          created_at?: string
          created_by?: string
          entrypoint?: string
          file_count?: number
          id?: string
          origin?: string
          tenant_id?: string
          total_bytes?: number
          tree_sha256?: string
          workspace_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "file_set_tenant_id_workspace_id_fkey"
            columns: ["tenant_id", "workspace_id"]
            isOneToOne: false
            referencedRelation: "workspace"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      file_set_entry: {
        Row: {
          artifact_id: string
          file_set_id: string
          id: string
          media_type: string
          path: string
          sha256: string
          size_bytes: number
          tenant_id: string
          workspace_id: string
        }
        Insert: {
          artifact_id: string
          file_set_id: string
          id?: string
          media_type: string
          path: string
          sha256: string
          size_bytes: number
          tenant_id: string
          workspace_id: string
        }
        Update: {
          artifact_id?: string
          file_set_id?: string
          id?: string
          media_type?: string
          path?: string
          sha256?: string
          size_bytes?: number
          tenant_id?: string
          workspace_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "file_set_entry_tenant_id_workspace_id_file_set_id_fkey"
            columns: ["tenant_id", "workspace_id", "file_set_id"]
            isOneToOne: false
            referencedRelation: "file_set"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
        ]
      }
      publisher_grant: {
        Row: {
          channel: string
          created_at: string
          granted_by: string | null
          id: string
          principal_id: string
          revoked_at: string | null
          tenant_id: string
        }
        Insert: {
          channel: string
          created_at?: string
          granted_by?: string | null
          id?: string
          principal_id: string
          revoked_at?: string | null
          tenant_id: string
        }
        Update: {
          channel?: string
          created_at?: string
          granted_by?: string | null
          id?: string
          principal_id?: string
          revoked_at?: string | null
          tenant_id?: string
        }
        Relationships: []
      }
      release: {
        Row: {
          approved_event_id: string
          audience_ceiling: string
          closure_sha256: string
          created_at: string
          created_by: string
          id: string
          manifest_artifact_id: string
          release_no: number
          root_revision_id: string
          root_work_id: string
          tenant_id: string
          workspace_id: string
        }
        Insert: {
          approved_event_id: string
          audience_ceiling: string
          closure_sha256: string
          created_at?: string
          created_by: string
          id?: string
          manifest_artifact_id: string
          release_no: number
          root_revision_id: string
          root_work_id: string
          tenant_id: string
          workspace_id: string
        }
        Update: {
          approved_event_id?: string
          audience_ceiling?: string
          closure_sha256?: string
          created_at?: string
          created_by?: string
          id?: string
          manifest_artifact_id?: string
          release_no?: number
          root_revision_id?: string
          root_work_id?: string
          tenant_id?: string
          workspace_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "release_tenant_id_workspace_id_approved_event_id_fkey"
            columns: ["tenant_id", "workspace_id", "approved_event_id"]
            isOneToOne: false
            referencedRelation: "event"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
          {
            foreignKeyName: "release_tenant_id_workspace_id_root_work_id_root_revision__fkey"
            columns: [
              "tenant_id",
              "workspace_id",
              "root_work_id",
              "root_revision_id",
            ]
            isOneToOne: false
            referencedRelation: "work_revision"
            referencedColumns: ["tenant_id", "workspace_id", "work_id", "id"]
          },
        ]
      }
      release_item: {
        Row: {
          artifact_id: string | null
          capture_id: string | null
          claim_id: string | null
          created_at: string
          decided_by: string | null
          disposition: string
          entity_id: string | null
          id: string
          item_key: string
          locator_id: string | null
          rationale: string | null
          record_id: string | null
          release_id: string
          revision_id: string | null
          substitute_artifact_id: string | null
          tenant_id: string
          via_binding_id: string | null
          workspace_id: string
        }
        Insert: {
          artifact_id?: string | null
          capture_id?: string | null
          claim_id?: string | null
          created_at?: string
          decided_by?: string | null
          disposition: string
          entity_id?: string | null
          id?: string
          item_key: string
          locator_id?: string | null
          rationale?: string | null
          record_id?: string | null
          release_id: string
          revision_id?: string | null
          substitute_artifact_id?: string | null
          tenant_id: string
          via_binding_id?: string | null
          workspace_id: string
        }
        Update: {
          artifact_id?: string | null
          capture_id?: string | null
          claim_id?: string | null
          created_at?: string
          decided_by?: string | null
          disposition?: string
          entity_id?: string | null
          id?: string
          item_key?: string
          locator_id?: string | null
          rationale?: string | null
          record_id?: string | null
          release_id?: string
          revision_id?: string | null
          substitute_artifact_id?: string | null
          tenant_id?: string
          via_binding_id?: string | null
          workspace_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "release_item_binding_fk"
            columns: ["tenant_id", "workspace_id", "via_binding_id"]
            isOneToOne: false
            referencedRelation: "revision_binding"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
          {
            foreignKeyName: "release_item_tenant_id_workspace_id_release_id_fkey"
            columns: ["tenant_id", "workspace_id", "release_id"]
            isOneToOne: false
            referencedRelation: "release"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
          {
            foreignKeyName: "release_item_tenant_id_workspace_id_revision_id_fkey"
            columns: ["tenant_id", "workspace_id", "revision_id"]
            isOneToOne: false
            referencedRelation: "work_revision"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
        ]
      }
      revision_binding: {
        Row: {
          artifact_id: string | null
          assertion_id: string | null
          block_key: string | null
          capture_id: string | null
          claim_id: string | null
          created_at: string
          entity_id: string | null
          file_set_id: string | null
          id: string
          local_key: string
          locator_id: string | null
          record_id: string | null
          relation: string
          release_item_id: string | null
          revision_id: string
          rights_basis: string
          role: string | null
          target_revision_id: string | null
          target_work_id: string | null
          tenant_id: string
          usage: string
          workspace_id: string
        }
        Insert: {
          artifact_id?: string | null
          assertion_id?: string | null
          block_key?: string | null
          capture_id?: string | null
          claim_id?: string | null
          created_at?: string
          entity_id?: string | null
          file_set_id?: string | null
          id?: string
          local_key: string
          locator_id?: string | null
          record_id?: string | null
          relation: string
          release_item_id?: string | null
          revision_id: string
          rights_basis: string
          role?: string | null
          target_revision_id?: string | null
          target_work_id?: string | null
          tenant_id: string
          usage: string
          workspace_id: string
        }
        Update: {
          artifact_id?: string | null
          assertion_id?: string | null
          block_key?: string | null
          capture_id?: string | null
          claim_id?: string | null
          created_at?: string
          entity_id?: string | null
          file_set_id?: string | null
          id?: string
          local_key?: string
          locator_id?: string | null
          record_id?: string | null
          relation?: string
          release_item_id?: string | null
          revision_id?: string
          rights_basis?: string
          role?: string | null
          target_revision_id?: string | null
          target_work_id?: string | null
          tenant_id?: string
          usage?: string
          workspace_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "revision_binding_tenant_id_release_item_id_fkey"
            columns: ["tenant_id", "release_item_id"]
            isOneToOne: false
            referencedRelation: "release_item"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "revision_binding_tenant_id_workspace_id_file_set_id_fkey"
            columns: ["tenant_id", "workspace_id", "file_set_id"]
            isOneToOne: false
            referencedRelation: "file_set"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
          {
            foreignKeyName: "revision_binding_tenant_id_workspace_id_revision_id_fkey"
            columns: ["tenant_id", "workspace_id", "revision_id"]
            isOneToOne: false
            referencedRelation: "work_revision"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
          {
            foreignKeyName: "revision_binding_tenant_id_workspace_id_target_revision_id_fkey"
            columns: ["tenant_id", "workspace_id", "target_revision_id"]
            isOneToOne: false
            referencedRelation: "work_revision"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
          {
            foreignKeyName: "revision_binding_tenant_id_workspace_id_target_work_id_fkey"
            columns: ["tenant_id", "workspace_id", "target_work_id"]
            isOneToOne: false
            referencedRelation: "work"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
        ]
      }
      revision_block: {
        Row: {
          block_key: string
          block_type: string
          content_sha256: string
          id: string
          parent_key: string | null
          position: number
          revision_id: string
          tenant_id: string
          workspace_id: string
        }
        Insert: {
          block_key: string
          block_type: string
          content_sha256: string
          id?: string
          parent_key?: string | null
          position: number
          revision_id: string
          tenant_id: string
          workspace_id: string
        }
        Update: {
          block_key?: string
          block_type?: string
          content_sha256?: string
          id?: string
          parent_key?: string | null
          position?: number
          revision_id?: string
          tenant_id?: string
          workspace_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "revision_block_block_type_fkey"
            columns: ["block_type"]
            isOneToOne: false
            referencedRelation: "block_type"
            referencedColumns: ["code"]
          },
          {
            foreignKeyName: "revision_block_tenant_id_workspace_id_revision_id_fkey"
            columns: ["tenant_id", "workspace_id", "revision_id"]
            isOneToOne: false
            referencedRelation: "work_revision"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
        ]
      }
      runtime_requirement: {
        Row: {
          created_at: string
          ecosystem: string | null
          entity_id: string | null
          id: string
          kind: string
          local_key: string
          name: string
          optional: boolean
          phase: string
          resolved_version: string | null
          revision_id: string
          tenant_id: string
          version_spec: string
          workspace_id: string
        }
        Insert: {
          created_at?: string
          ecosystem?: string | null
          entity_id?: string | null
          id?: string
          kind: string
          local_key: string
          name: string
          optional?: boolean
          phase: string
          resolved_version?: string | null
          revision_id: string
          tenant_id: string
          version_spec: string
          workspace_id: string
        }
        Update: {
          created_at?: string
          ecosystem?: string | null
          entity_id?: string | null
          id?: string
          kind?: string
          local_key?: string
          name?: string
          optional?: boolean
          phase?: string
          resolved_version?: string | null
          revision_id?: string
          tenant_id?: string
          version_spec?: string
          workspace_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "runtime_requirement_tenant_id_workspace_id_revision_id_fkey"
            columns: ["tenant_id", "workspace_id", "revision_id"]
            isOneToOne: false
            referencedRelation: "work_revision"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
        ]
      }
      work: {
        Row: {
          created_at: string
          created_by: string
          head_revision_id: string | null
          id: string
          kind: string
          slug: string
          tenant_id: string
          workspace_id: string
        }
        Insert: {
          created_at?: string
          created_by: string
          head_revision_id?: string | null
          id?: string
          kind: string
          slug: string
          tenant_id: string
          workspace_id: string
        }
        Update: {
          created_at?: string
          created_by?: string
          head_revision_id?: string | null
          id?: string
          kind?: string
          slug?: string
          tenant_id?: string
          workspace_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "work_head_fk"
            columns: ["tenant_id", "workspace_id", "id", "head_revision_id"]
            isOneToOne: false
            referencedRelation: "work_revision"
            referencedColumns: ["tenant_id", "workspace_id", "work_id", "id"]
          },
          {
            foreignKeyName: "work_tenant_id_workspace_id_fkey"
            columns: ["tenant_id", "workspace_id"]
            isOneToOne: false
            referencedRelation: "workspace"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      work_revision: {
        Row: {
          body: Json
          body_schema: string
          content_sha256: string | null
          created_at: string
          created_by: string
          id: string
          knowledge_seq: number | null
          origin: string
          origin_ref: Json
          parent_revision_id: string | null
          purged_at: string | null
          purged_by_removal_id: string | null
          revision_no: number
          tenant_id: string
          title: string
          work_id: string
          workspace_id: string
          world_from: string | null
          world_precision: string
          world_to: string | null
        }
        Insert: {
          body: Json
          body_schema: string
          content_sha256?: string | null
          created_at?: string
          created_by: string
          id?: string
          knowledge_seq?: number | null
          origin: string
          origin_ref?: Json
          parent_revision_id?: string | null
          purged_at?: string | null
          purged_by_removal_id?: string | null
          revision_no: number
          tenant_id: string
          title: string
          work_id: string
          workspace_id: string
          world_from?: string | null
          world_precision?: string
          world_to?: string | null
        }
        Update: {
          body?: Json
          body_schema?: string
          content_sha256?: string | null
          created_at?: string
          created_by?: string
          id?: string
          knowledge_seq?: number | null
          origin?: string
          origin_ref?: Json
          parent_revision_id?: string | null
          purged_at?: string | null
          purged_by_removal_id?: string | null
          revision_no?: number
          tenant_id?: string
          title?: string
          work_id?: string
          workspace_id?: string
          world_from?: string | null
          world_precision?: string
          world_to?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "work_revision_tenant_id_workspace_id_work_id_fkey"
            columns: ["tenant_id", "workspace_id", "work_id"]
            isOneToOne: false
            referencedRelation: "work"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
          {
            foreignKeyName: "work_revision_tenant_id_workspace_id_work_id_parent_revisi_fkey"
            columns: [
              "tenant_id",
              "workspace_id",
              "work_id",
              "parent_revision_id",
            ]
            isOneToOne: false
            referencedRelation: "work_revision"
            referencedColumns: ["tenant_id", "workspace_id", "work_id", "id"]
          },
        ]
      }
      workspace: {
        Row: {
          created_at: string
          id: string
          kind: string
          name: string
          owner_id: string
          tenant_id: string
        }
        Insert: {
          created_at?: string
          id?: string
          kind?: string
          name: string
          owner_id: string
          tenant_id: string
        }
        Update: {
          created_at?: string
          id?: string
          kind?: string
          name?: string
          owner_id?: string
          tenant_id?: string
        }
        Relationships: []
      }
      workspace_member: {
        Row: {
          created_at: string
          granted_by: string
          id: string
          principal_id: string
          revoked_at: string | null
          role: string
          tenant_id: string
          workspace_id: string
        }
        Insert: {
          created_at?: string
          granted_by: string
          id?: string
          principal_id: string
          revoked_at?: string | null
          role: string
          tenant_id: string
          workspace_id: string
        }
        Update: {
          created_at?: string
          granted_by?: string
          id?: string
          principal_id?: string
          revoked_at?: string | null
          role?: string
          tenant_id?: string
          workspace_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "workspace_member_tenant_id_workspace_id_fkey"
            columns: ["tenant_id", "workspace_id"]
            isOneToOne: false
            referencedRelation: "workspace"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  catalog: {
    Tables: {
      distribution_kind: {
        Row: {
          code: string
          description: string
        }
        Insert: {
          code: string
          description: string
        }
        Update: {
          code?: string
          description?: string
        }
        Relationships: []
      }
      entity: {
        Row: {
          attributes: Json
          created_at: string
          created_by_receipt_id: string
          display_name: string
          id: string
          kind: string
          lifecycle: string
          merged_into_id: string | null
          projection_knowledge_seq: number | null
          slug: string
          summary: string | null
          tenant_id: string
          updated_at: string
        }
        Insert: {
          attributes?: Json
          created_at?: string
          created_by_receipt_id: string
          display_name: string
          id?: string
          kind: string
          lifecycle?: string
          merged_into_id?: string | null
          projection_knowledge_seq?: number | null
          slug: string
          summary?: string | null
          tenant_id?: string
          updated_at?: string
        }
        Update: {
          attributes?: Json
          created_at?: string
          created_by_receipt_id?: string
          display_name?: string
          id?: string
          kind?: string
          lifecycle?: string
          merged_into_id?: string | null
          projection_knowledge_seq?: number | null
          slug?: string
          summary?: string | null
          tenant_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "entity_merged_into_id_fkey"
            columns: ["merged_into_id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "entity_tenant_id_merged_into_id_fkey"
            columns: ["tenant_id", "merged_into_id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      entity_alias: {
        Row: {
          alias: string
          alias_kind: string
          alias_normalized: string | null
          entity_id: string
          id: string
          language: string | null
          source_claim_id: string | null
          tenant_id: string
        }
        Insert: {
          alias: string
          alias_kind: string
          alias_normalized?: string | null
          entity_id: string
          id?: string
          language?: string | null
          source_claim_id?: string | null
          tenant_id?: string
        }
        Update: {
          alias?: string
          alias_kind?: string
          alias_normalized?: string | null
          entity_id?: string
          id?: string
          language?: string | null
          source_claim_id?: string | null
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "entity_alias_entity_id_fkey"
            columns: ["entity_id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "entity_alias_tenant_id_entity_id_fkey"
            columns: ["tenant_id", "entity_id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      entity_identifier: {
        Row: {
          entity_id: string
          id: string
          scheme: string
          tenant_id: string
          value: string
        }
        Insert: {
          entity_id: string
          id?: string
          scheme: string
          tenant_id?: string
          value: string
        }
        Update: {
          entity_id?: string
          id?: string
          scheme?: string
          tenant_id?: string
          value?: string
        }
        Relationships: [
          {
            foreignKeyName: "entity_identifier_entity_id_fkey"
            columns: ["entity_id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "entity_identifier_tenant_id_entity_id_fkey"
            columns: ["tenant_id", "entity_id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      entity_merge: {
        Row: {
          created_at: string
          from_entity_id: string
          id: string
          knowledge_seq: number | null
          note: string | null
          proposal_id: string | null
          reason: string
          reason_code: string | null
          receipt_id: string
          tenant_id: string
          to_entity_id: string
          undone_at: string | null
          undone_receipt_id: string | null
        }
        Insert: {
          created_at?: string
          from_entity_id: string
          id?: string
          knowledge_seq?: number | null
          note?: string | null
          proposal_id?: string | null
          reason: string
          reason_code?: string | null
          receipt_id: string
          tenant_id?: string
          to_entity_id: string
          undone_at?: string | null
          undone_receipt_id?: string | null
        }
        Update: {
          created_at?: string
          from_entity_id?: string
          id?: string
          knowledge_seq?: number | null
          note?: string | null
          proposal_id?: string | null
          reason?: string
          reason_code?: string | null
          receipt_id?: string
          tenant_id?: string
          to_entity_id?: string
          undone_at?: string | null
          undone_receipt_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "entity_merge_from_entity_id_fkey"
            columns: ["from_entity_id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "entity_merge_proposal_id_fkey"
            columns: ["proposal_id"]
            isOneToOne: false
            referencedRelation: "proposal"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "entity_merge_tenant_id_from_entity_id_fkey"
            columns: ["tenant_id", "from_entity_id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "entity_merge_tenant_id_to_entity_id_fkey"
            columns: ["tenant_id", "to_entity_id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "entity_merge_to_entity_id_fkey"
            columns: ["to_entity_id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
        ]
      }
      entity_split: {
        Row: {
          created_at: string
          from_entity_id: string
          id: string
          knowledge_seq: number | null
          note: string | null
          proposal_id: string | null
          reason_code: string
          receipt_id: string
          source_retired: boolean
          tenant_id: string
          undone_at: string | null
        }
        Insert: {
          created_at?: string
          from_entity_id: string
          id?: string
          knowledge_seq?: number | null
          note?: string | null
          proposal_id?: string | null
          reason_code: string
          receipt_id: string
          source_retired?: boolean
          tenant_id?: string
          undone_at?: string | null
        }
        Update: {
          created_at?: string
          from_entity_id?: string
          id?: string
          knowledge_seq?: number | null
          note?: string | null
          proposal_id?: string | null
          reason_code?: string
          receipt_id?: string
          source_retired?: boolean
          tenant_id?: string
          undone_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "entity_split_from_entity_id_fkey"
            columns: ["from_entity_id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "entity_split_proposal_id_fkey"
            columns: ["proposal_id"]
            isOneToOne: false
            referencedRelation: "proposal"
            referencedColumns: ["id"]
          },
        ]
      }
      entity_split_part: {
        Row: {
          split_id: string
          tenant_id: string
          to_entity_id: string
        }
        Insert: {
          split_id: string
          tenant_id?: string
          to_entity_id: string
        }
        Update: {
          split_id?: string
          tenant_id?: string
          to_entity_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "entity_split_part_split_id_fkey"
            columns: ["split_id"]
            isOneToOne: false
            referencedRelation: "entity_split"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "entity_split_part_to_entity_id_fkey"
            columns: ["to_entity_id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
        ]
      }
      identity_move: {
        Row: {
          action: string
          column_name: string | null
          created_at: string
          detail: Json
          id: string
          merge_id: string | null
          row_key: Json
          seq: number
          split_id: string | null
          table_name: string
          tenant_id: string
          undone: boolean
        }
        Insert: {
          action: string
          column_name?: string | null
          created_at?: string
          detail?: Json
          id?: string
          merge_id?: string | null
          row_key: Json
          seq?: never
          split_id?: string | null
          table_name: string
          tenant_id?: string
          undone?: boolean
        }
        Update: {
          action?: string
          column_name?: string | null
          created_at?: string
          detail?: Json
          id?: string
          merge_id?: string | null
          row_key?: Json
          seq?: never
          split_id?: string | null
          table_name?: string
          tenant_id?: string
          undone?: boolean
        }
        Relationships: [
          {
            foreignKeyName: "identity_move_merge_id_fkey"
            columns: ["merge_id"]
            isOneToOne: false
            referencedRelation: "entity_merge"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "identity_move_split_id_fkey"
            columns: ["split_id"]
            isOneToOne: false
            referencedRelation: "entity_split"
            referencedColumns: ["id"]
          },
        ]
      }
      license: {
        Row: {
          code: string
          name: string
          spdx_id: string | null
          url: string | null
        }
        Insert: {
          code: string
          name: string
          spdx_id?: string | null
          url?: string | null
        }
        Update: {
          code?: string
          name?: string
          spdx_id?: string | null
          url?: string | null
        }
        Relationships: []
      }
      media_platform: {
        Row: {
          channel_url_template: string | null
          code: string
          media_url_template: string | null
          name: string
          product_entity_id: string | null
          timecode_param: string | null
        }
        Insert: {
          channel_url_template?: string | null
          code: string
          media_url_template?: string | null
          name: string
          product_entity_id?: string | null
          timecode_param?: string | null
        }
        Update: {
          channel_url_template?: string | null
          code?: string
          media_url_template?: string | null
          name?: string
          product_entity_id?: string | null
          timecode_param?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "media_platform_product_entity_id_fkey"
            columns: ["product_entity_id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
        ]
      }
      proposal: {
        Row: {
          authored_by: string
          authored_by_kind: string
          cause_event_id: string | null
          confidence: string
          created_at: string
          created_by_receipt_id: string | null
          decided_at: string | null
          decided_by: string | null
          decision_note: string | null
          id: string
          label: string | null
          object_entity_id: string | null
          outcome_claim_id: string | null
          proposal_kind: string
          publication: string
          published_at: string | null
          published_by: string | null
          rationale: string
          relationship_kind: string | null
          review_state: string
          statement: string
          subject_entity_id: string | null
          target_event_id: string | null
          target_relationship_id: string | null
          target_segment_id: string | null
          tenant_id: string
          updated_at: string
          world_during: unknown
        }
        Insert: {
          authored_by: string
          authored_by_kind: string
          cause_event_id?: string | null
          confidence: string
          created_at?: string
          created_by_receipt_id?: string | null
          decided_at?: string | null
          decided_by?: string | null
          decision_note?: string | null
          id?: string
          label?: string | null
          object_entity_id?: string | null
          outcome_claim_id?: string | null
          proposal_kind: string
          publication?: string
          published_at?: string | null
          published_by?: string | null
          rationale: string
          relationship_kind?: string | null
          review_state?: string
          statement: string
          subject_entity_id?: string | null
          target_event_id?: string | null
          target_relationship_id?: string | null
          target_segment_id?: string | null
          tenant_id?: string
          updated_at?: string
          world_during?: unknown
        }
        Update: {
          authored_by?: string
          authored_by_kind?: string
          cause_event_id?: string | null
          confidence?: string
          created_at?: string
          created_by_receipt_id?: string | null
          decided_at?: string | null
          decided_by?: string | null
          decision_note?: string | null
          id?: string
          label?: string | null
          object_entity_id?: string | null
          outcome_claim_id?: string | null
          proposal_kind?: string
          publication?: string
          published_at?: string | null
          published_by?: string | null
          rationale?: string
          relationship_kind?: string | null
          review_state?: string
          statement?: string
          subject_entity_id?: string | null
          target_event_id?: string | null
          target_relationship_id?: string | null
          target_segment_id?: string | null
          tenant_id?: string
          updated_at?: string
          world_during?: unknown
        }
        Relationships: [
          {
            foreignKeyName: "proposal_object_entity_id_fkey"
            columns: ["object_entity_id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "proposal_subject_entity_id_fkey"
            columns: ["subject_entity_id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "proposal_target_relationship_id_fkey"
            columns: ["target_relationship_id"]
            isOneToOne: false
            referencedRelation: "relationship"
            referencedColumns: ["id"]
          },
        ]
      }
      proposal_basis: {
        Row: {
          claim_id: string | null
          event_id: string | null
          id: string
          note: string | null
          proposal_id: string
          relationship_id: string | null
          role: string
          segment_id: string | null
          tenant_id: string
        }
        Insert: {
          claim_id?: string | null
          event_id?: string | null
          id?: string
          note?: string | null
          proposal_id: string
          relationship_id?: string | null
          role?: string
          segment_id?: string | null
          tenant_id?: string
        }
        Update: {
          claim_id?: string | null
          event_id?: string | null
          id?: string
          note?: string | null
          proposal_id?: string
          relationship_id?: string | null
          role?: string
          segment_id?: string | null
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "proposal_basis_proposal_id_fkey"
            columns: ["proposal_id"]
            isOneToOne: false
            referencedRelation: "proposal"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "proposal_basis_relationship_id_fkey"
            columns: ["relationship_id"]
            isOneToOne: false
            referencedRelation: "relationship"
            referencedColumns: ["id"]
          },
        ]
      }
      relationship: {
        Row: {
          closed_by_event_id: string | null
          closed_kind: string | null
          closed_reason: string | null
          created_at: string
          episode: number
          from_entity_id: string
          id: string
          k_from: number
          k_to: number | null
          kind: string
          primary_claim_id: string | null
          properties: Json
          qualifier: string
          tenant_id: string
          to_entity_id: string
        }
        Insert: {
          closed_by_event_id?: string | null
          closed_kind?: string | null
          closed_reason?: string | null
          created_at?: string
          episode?: number
          from_entity_id: string
          id?: string
          k_from: number
          k_to?: number | null
          kind: string
          primary_claim_id?: string | null
          properties?: Json
          qualifier?: string
          tenant_id?: string
          to_entity_id: string
        }
        Update: {
          closed_by_event_id?: string | null
          closed_kind?: string | null
          closed_reason?: string | null
          created_at?: string
          episode?: number
          from_entity_id?: string
          id?: string
          k_from?: number
          k_to?: number | null
          kind?: string
          primary_claim_id?: string | null
          properties?: Json
          qualifier?: string
          tenant_id?: string
          to_entity_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "relationship_from_entity_id_fkey"
            columns: ["from_entity_id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "relationship_tenant_id_from_entity_id_fkey"
            columns: ["tenant_id", "from_entity_id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "relationship_tenant_id_to_entity_id_fkey"
            columns: ["tenant_id", "to_entity_id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "relationship_to_entity_id_fkey"
            columns: ["to_entity_id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
        ]
      }
      work: {
        Row: {
          abstract: string | null
          attributes: Json
          canonical_url: string | null
          duration_ms: number | null
          id: string
          kind: string
          language: string | null
          published_at: string | null
          subtitle: string | null
          tenant_id: string
          title: string
          venue_entity_id: string | null
        }
        Insert: {
          abstract?: string | null
          attributes?: Json
          canonical_url?: string | null
          duration_ms?: number | null
          id: string
          kind: string
          language?: string | null
          published_at?: string | null
          subtitle?: string | null
          tenant_id?: string
          title: string
          venue_entity_id?: string | null
        }
        Update: {
          abstract?: string | null
          attributes?: Json
          canonical_url?: string | null
          duration_ms?: number | null
          id?: string
          kind?: string
          language?: string | null
          published_at?: string | null
          subtitle?: string | null
          tenant_id?: string
          title?: string
          venue_entity_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "work_id_fkey"
            columns: ["id"]
            isOneToOne: true
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "work_tenant_id_id_kind_fkey"
            columns: ["tenant_id", "id", "kind"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id", "kind"]
          },
          {
            foreignKeyName: "work_venue_entity_id_fkey"
            columns: ["venue_entity_id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      _carry_relationship_streams: {
        Args: { p_from_rel: string; p_reason: string; p_to_rel: string }
        Returns: undefined
      }
      _ensure_stream: {
        Args: {
          p_entity: string
          p_kind: string
          p_relationship: string
          p_scope_key: string
        }
        Returns: string
      }
      _log_move: {
        Args: {
          p_action: string
          p_column: string
          p_detail?: Json
          p_merge: string
          p_row_key: Json
          p_split: string
          p_table: string
        }
        Returns: undefined
      }
      _move_relationship: {
        Args: {
          p_from: string
          p_reason: string
          p_relationship: string
          p_to: string
        }
        Returns: string
      }
      _move_segment: {
        Args: {
          p_reason: string
          p_ref: string
          p_segment: string
          p_stream: string
        }
        Returns: string
      }
      _reopen_segment: {
        Args: { p_reason: string; p_segment: string }
        Returns: string
      }
      _repoint_references: {
        Args: { p_from: string; p_merge: string; p_split: string; p_to: string }
        Returns: number
      }
      _row_key: { Args: { p_row: Json; p_table: unknown }; Returns: Json }
      caller_is_person: { Args: never; Returns: boolean }
      caller_role: { Args: never; Returns: string }
      canonical_entity: { Args: { p_entity: string }; Returns: string }
      entity_references: {
        Args: { p_entity: string }
        Returns: {
          column_name: string
          row_count: number
          table_name: string
        }[]
      }
      import_research_starter_catalog: {
        Args: { p_receipt: string }
        Returns: Json
      }
      merge_entities: {
        Args: {
          p_loser: string
          p_note?: string
          p_proposal?: string
          p_reason?: string
          p_receipt: string
          p_winner: string
        }
        Returns: Json
      }
      rebuild_entity_projections: { Args: { p_k?: number }; Returns: number }
      split_entity: {
        Args: {
          p_note?: string
          p_parts: Json
          p_proposal?: string
          p_reason?: string
          p_receipt: string
          p_retire_source?: boolean
          p_source: string
        }
        Returns: Json
      }
      undo_merge: {
        Args: { p_merge: string; p_note?: string; p_receipt: string }
        Returns: Json
      }
      with_merged: { Args: { p_ids: string[] }; Returns: string[] }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  content: {
    Tables: {
      conversion_evaluation: {
        Row: {
          conversion_grade: string
          coverage: number | null
          created_at: string
          disposition: string
          evaluator_identity: string
          findings_sha256: string
          id: string
          locator_coverage: number | null
          procedure_version: string
          report_artifact_id: string | null
          representation_id: string
          tenant_id: string
        }
        Insert: {
          conversion_grade: string
          coverage?: number | null
          created_at?: string
          disposition: string
          evaluator_identity: string
          findings_sha256: string
          id?: string
          locator_coverage?: number | null
          procedure_version: string
          report_artifact_id?: string | null
          representation_id: string
          tenant_id?: string
        }
        Update: {
          conversion_grade?: string
          coverage?: number | null
          created_at?: string
          disposition?: string
          evaluator_identity?: string
          findings_sha256?: string
          id?: string
          locator_coverage?: number | null
          procedure_version?: string
          report_artifact_id?: string | null
          representation_id?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "conversion_evaluation_tenant_id_representation_id_fkey"
            columns: ["tenant_id", "representation_id"]
            isOneToOne: false
            referencedRelation: "document_representation"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      conversion_finding: {
        Row: {
          conversion_evaluation_id: string
          created_at: string
          evidence_artifact_id: string | null
          expected_behavior: string | null
          finding_kind: string
          id: string
          locator_id: string | null
          node_id: string | null
          observed_defect: string
          recommended_action: string | null
          resolution: string | null
          severity: string
          tenant_id: string
        }
        Insert: {
          conversion_evaluation_id: string
          created_at?: string
          evidence_artifact_id?: string | null
          expected_behavior?: string | null
          finding_kind: string
          id?: string
          locator_id?: string | null
          node_id?: string | null
          observed_defect: string
          recommended_action?: string | null
          resolution?: string | null
          severity: string
          tenant_id?: string
        }
        Update: {
          conversion_evaluation_id?: string
          created_at?: string
          evidence_artifact_id?: string | null
          expected_behavior?: string | null
          finding_kind?: string
          id?: string
          locator_id?: string | null
          node_id?: string | null
          observed_defect?: string
          recommended_action?: string | null
          resolution?: string | null
          severity?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "conversion_finding_tenant_id_conversion_evaluation_id_fkey"
            columns: ["tenant_id", "conversion_evaluation_id"]
            isOneToOne: false
            referencedRelation: "conversion_evaluation"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "conversion_finding_tenant_id_node_id_fkey"
            columns: ["tenant_id", "node_id"]
            isOneToOne: false
            referencedRelation: "document_node"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      digest_item: {
        Row: {
          claim_id: string | null
          confidence: number | null
          digest_id: string
          entity_id: string | null
          id: string
          item_kind: string
          node_ids: string[]
          ordinal: number
          payload: Json
          tenant_id: string
          text: string | null
          unit_change_id: string | null
        }
        Insert: {
          claim_id?: string | null
          confidence?: number | null
          digest_id: string
          entity_id?: string | null
          id?: string
          item_kind: string
          node_ids?: string[]
          ordinal: number
          payload?: Json
          tenant_id?: string
          text?: string | null
          unit_change_id?: string | null
        }
        Update: {
          claim_id?: string | null
          confidence?: number | null
          digest_id?: string
          entity_id?: string | null
          id?: string
          item_kind?: string
          node_ids?: string[]
          ordinal?: number
          payload?: Json
          tenant_id?: string
          text?: string | null
          unit_change_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "digest_item_digest_id_fkey"
            columns: ["digest_id"]
            isOneToOne: false
            referencedRelation: "document_digest"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "digest_item_unit_change_id_fkey"
            columns: ["unit_change_id"]
            isOneToOne: false
            referencedRelation: "unit_change"
            referencedColumns: ["id"]
          },
        ]
      }
      document: {
        Row: {
          attributes: Json
          canonical_source_id: string | null
          canonical_title: string
          created_at: string
          created_by_attempt_id: string | null
          document_type_code: string
          id: string
          lifecycle: string
          source_role_code: string | null
          source_role_method: string | null
          supersedes_id: string | null
          tenant_id: string
          work_entity_id: string | null
        }
        Insert: {
          attributes?: Json
          canonical_source_id?: string | null
          canonical_title: string
          created_at?: string
          created_by_attempt_id?: string | null
          document_type_code: string
          id?: string
          lifecycle?: string
          source_role_code?: string | null
          source_role_method?: string | null
          supersedes_id?: string | null
          tenant_id?: string
          work_entity_id?: string | null
        }
        Update: {
          attributes?: Json
          canonical_source_id?: string | null
          canonical_title?: string
          created_at?: string
          created_by_attempt_id?: string | null
          document_type_code?: string
          id?: string
          lifecycle?: string
          source_role_code?: string | null
          source_role_method?: string | null
          supersedes_id?: string | null
          tenant_id?: string
          work_entity_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "document_document_type_code_fkey"
            columns: ["document_type_code"]
            isOneToOne: false
            referencedRelation: "document_type"
            referencedColumns: ["code"]
          },
          {
            foreignKeyName: "document_source_role_code_fkey"
            columns: ["source_role_code"]
            isOneToOne: false
            referencedRelation: "source_role"
            referencedColumns: ["code"]
          },
          {
            foreignKeyName: "document_tenant_id_supersedes_id_fkey"
            columns: ["tenant_id", "supersedes_id"]
            isOneToOne: false
            referencedRelation: "document"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      document_about_entity: {
        Row: {
          confidence: number | null
          document_id: string
          entity_id: string
          method: string
          role: string
          tenant_id: string
        }
        Insert: {
          confidence?: number | null
          document_id: string
          entity_id: string
          method: string
          role: string
          tenant_id?: string
        }
        Update: {
          confidence?: number | null
          document_id?: string
          entity_id?: string
          method?: string
          role?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "document_about_entity_document_id_fkey"
            columns: ["document_id"]
            isOneToOne: false
            referencedRelation: "document"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "document_about_entity_tenant_id_document_id_fkey"
            columns: ["tenant_id", "document_id"]
            isOneToOne: false
            referencedRelation: "document"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      document_digest: {
        Row: {
          created_at: string
          digest_schema_version: string
          document_version_id: string
          focus_entity_id: string | null
          id: string
          lifecycle: string
          producer_identity: string
          producer_kind: string
          scope: string
          scope_node_id: string | null
          tenant_id: string
          transformation_run_id: string | null
        }
        Insert: {
          created_at?: string
          digest_schema_version?: string
          document_version_id: string
          focus_entity_id?: string | null
          id?: string
          lifecycle?: string
          producer_identity: string
          producer_kind: string
          scope: string
          scope_node_id?: string | null
          tenant_id?: string
          transformation_run_id?: string | null
        }
        Update: {
          created_at?: string
          digest_schema_version?: string
          document_version_id?: string
          focus_entity_id?: string | null
          id?: string
          lifecycle?: string
          producer_identity?: string
          producer_kind?: string
          scope?: string
          scope_node_id?: string | null
          tenant_id?: string
          transformation_run_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "document_digest_tenant_id_document_version_id_fkey"
            columns: ["tenant_id", "document_version_id"]
            isOneToOne: false
            referencedRelation: "document_version"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "document_digest_tenant_id_scope_node_id_fkey"
            columns: ["tenant_id", "scope_node_id"]
            isOneToOne: false
            referencedRelation: "document_node"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "document_digest_tenant_id_transformation_run_id_fkey"
            columns: ["tenant_id", "transformation_run_id"]
            isOneToOne: false
            referencedRelation: "transformation_run"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      document_identifier: {
        Row: {
          authority: string | null
          created_at: string
          document_id: string
          id: string
          identifier_type: string
          normalized_value: string
          tenant_id: string
          valid_from: string | null
          valid_to: string | null
        }
        Insert: {
          authority?: string | null
          created_at?: string
          document_id: string
          id?: string
          identifier_type: string
          normalized_value: string
          tenant_id?: string
          valid_from?: string | null
          valid_to?: string | null
        }
        Update: {
          authority?: string | null
          created_at?: string
          document_id?: string
          id?: string
          identifier_type?: string
          normalized_value?: string
          tenant_id?: string
          valid_from?: string | null
          valid_to?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "document_identifier_tenant_id_document_id_fkey"
            columns: ["tenant_id", "document_id"]
            isOneToOne: false
            referencedRelation: "document"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      document_kind_assignment: {
        Row: {
          assigned_at: string
          confidence: number | null
          document_id: string
          document_type_code: string
          id: string
          method: string
          rationale: string | null
          superseded_by_id: string | null
          tenant_id: string
        }
        Insert: {
          assigned_at?: string
          confidence?: number | null
          document_id: string
          document_type_code: string
          id?: string
          method: string
          rationale?: string | null
          superseded_by_id?: string | null
          tenant_id?: string
        }
        Update: {
          assigned_at?: string
          confidence?: number | null
          document_id?: string
          document_type_code?: string
          id?: string
          method?: string
          rationale?: string | null
          superseded_by_id?: string | null
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "document_kind_assignment_document_type_code_fkey"
            columns: ["document_type_code"]
            isOneToOne: false
            referencedRelation: "document_type"
            referencedColumns: ["code"]
          },
          {
            foreignKeyName: "document_kind_assignment_superseded_by_id_fkey"
            columns: ["superseded_by_id"]
            isOneToOne: false
            referencedRelation: "document_kind_assignment"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "document_kind_assignment_tenant_id_document_id_fkey"
            columns: ["tenant_id", "document_id"]
            isOneToOne: false
            referencedRelation: "document"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      document_node: {
        Row: {
          artifact_id: string | null
          attributes: Json
          bbox: Json | null
          created_at: string
          end_ms: number | null
          end_offset: number | null
          grammar_version: string | null
          id: string
          inline_text: string | null
          language: string | null
          logical_key: string | null
          normalized_content_sha256: string
          ordinal: number
          page_number: number | null
          parent_id: string | null
          representation_id: string
          role: string | null
          selector: Json
          speaker_entity_id: string | null
          stable_local_key: string
          start_ms: number | null
          start_offset: number | null
          tenant_id: string
          unit_kind: string
          unit_kind_version: number
        }
        Insert: {
          artifact_id?: string | null
          attributes?: Json
          bbox?: Json | null
          created_at?: string
          end_ms?: number | null
          end_offset?: number | null
          grammar_version?: string | null
          id?: string
          inline_text?: string | null
          language?: string | null
          logical_key?: string | null
          normalized_content_sha256: string
          ordinal: number
          page_number?: number | null
          parent_id?: string | null
          representation_id: string
          role?: string | null
          selector?: Json
          speaker_entity_id?: string | null
          stable_local_key: string
          start_ms?: number | null
          start_offset?: number | null
          tenant_id?: string
          unit_kind: string
          unit_kind_version?: number
        }
        Update: {
          artifact_id?: string | null
          attributes?: Json
          bbox?: Json | null
          created_at?: string
          end_ms?: number | null
          end_offset?: number | null
          grammar_version?: string | null
          id?: string
          inline_text?: string | null
          language?: string | null
          logical_key?: string | null
          normalized_content_sha256?: string
          ordinal?: number
          page_number?: number | null
          parent_id?: string | null
          representation_id?: string
          role?: string | null
          selector?: Json
          speaker_entity_id?: string | null
          stable_local_key?: string
          start_ms?: number | null
          start_offset?: number | null
          tenant_id?: string
          unit_kind?: string
          unit_kind_version?: number
        }
        Relationships: [
          {
            foreignKeyName: "document_node_tenant_id_parent_id_fkey"
            columns: ["tenant_id", "parent_id"]
            isOneToOne: false
            referencedRelation: "document_node"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "document_node_tenant_id_representation_id_fkey"
            columns: ["tenant_id", "representation_id"]
            isOneToOne: false
            referencedRelation: "document_representation"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "document_node_unit_kind_fkey"
            columns: ["unit_kind", "unit_kind_version"]
            isOneToOne: false
            referencedRelation: "unit_kind"
            referencedColumns: ["code", "version"]
          },
        ]
      }
      document_node_edge: {
        Row: {
          created_at: string
          from_node_id: string
          metadata: Json
          relation_kind: string
          tenant_id: string
          to_node_id: string
        }
        Insert: {
          created_at?: string
          from_node_id: string
          metadata?: Json
          relation_kind: string
          tenant_id?: string
          to_node_id: string
        }
        Update: {
          created_at?: string
          from_node_id?: string
          metadata?: Json
          relation_kind?: string
          tenant_id?: string
          to_node_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "document_node_edge_tenant_id_from_node_id_fkey"
            columns: ["tenant_id", "from_node_id"]
            isOneToOne: false
            referencedRelation: "document_node"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "document_node_edge_tenant_id_to_node_id_fkey"
            columns: ["tenant_id", "to_node_id"]
            isOneToOne: false
            referencedRelation: "document_node"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      document_representation: {
        Row: {
          acceptance_state: string
          artifact_id: string
          content_sha256: string
          created_at: string
          document_version_id: string
          grammar_version: string | null
          id: string
          language: string | null
          media_type: string
          representation_class: string
          representation_kind: string
          source_native_byte_identical: boolean
          supersedes_id: string | null
          tenant_id: string
          transformation_run_id: string | null
        }
        Insert: {
          acceptance_state?: string
          artifact_id: string
          content_sha256: string
          created_at?: string
          document_version_id: string
          grammar_version?: string | null
          id?: string
          language?: string | null
          media_type: string
          representation_class: string
          representation_kind: string
          source_native_byte_identical?: boolean
          supersedes_id?: string | null
          tenant_id?: string
          transformation_run_id?: string | null
        }
        Update: {
          acceptance_state?: string
          artifact_id?: string
          content_sha256?: string
          created_at?: string
          document_version_id?: string
          grammar_version?: string | null
          id?: string
          language?: string | null
          media_type?: string
          representation_class?: string
          representation_kind?: string
          source_native_byte_identical?: boolean
          supersedes_id?: string | null
          tenant_id?: string
          transformation_run_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "document_representation_tenant_id_document_version_id_fkey"
            columns: ["tenant_id", "document_version_id"]
            isOneToOne: false
            referencedRelation: "document_version"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "document_representation_tenant_id_supersedes_id_fkey"
            columns: ["tenant_id", "supersedes_id"]
            isOneToOne: false
            referencedRelation: "document_representation"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "document_representation_tenant_id_transformation_run_id_fkey"
            columns: ["tenant_id", "transformation_run_id"]
            isOneToOne: false
            referencedRelation: "transformation_run"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      document_summary: {
        Row: {
          audience: string
          content_sha256: string
          coverage_ratio: number | null
          created_at: string
          derived_from_representation_id: string
          digest_id: string | null
          document_version_id: string
          focus_entity_id: string | null
          id: string
          language: string | null
          lifecycle: string
          representation_id: string
          scope: string
          scope_node_id: string | null
          summary_kind: string
          supersedes_id: string | null
          tenant_id: string
          text: string
          token_count: number
          transformation_run_id: string
        }
        Insert: {
          audience?: string
          content_sha256: string
          coverage_ratio?: number | null
          created_at?: string
          derived_from_representation_id: string
          digest_id?: string | null
          document_version_id: string
          focus_entity_id?: string | null
          id?: string
          language?: string | null
          lifecycle?: string
          representation_id: string
          scope: string
          scope_node_id?: string | null
          summary_kind: string
          supersedes_id?: string | null
          tenant_id?: string
          text: string
          token_count: number
          transformation_run_id: string
        }
        Update: {
          audience?: string
          content_sha256?: string
          coverage_ratio?: number | null
          created_at?: string
          derived_from_representation_id?: string
          digest_id?: string | null
          document_version_id?: string
          focus_entity_id?: string | null
          id?: string
          language?: string | null
          lifecycle?: string
          representation_id?: string
          scope?: string
          scope_node_id?: string | null
          summary_kind?: string
          supersedes_id?: string | null
          tenant_id?: string
          text?: string
          token_count?: number
          transformation_run_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "document_summary_derived_from_representation_id_fkey"
            columns: ["derived_from_representation_id"]
            isOneToOne: false
            referencedRelation: "document_representation"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "document_summary_digest_id_fkey"
            columns: ["digest_id"]
            isOneToOne: false
            referencedRelation: "document_digest"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "document_summary_document_version_id_fkey"
            columns: ["document_version_id"]
            isOneToOne: false
            referencedRelation: "document_version"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "document_summary_representation_id_fkey"
            columns: ["representation_id"]
            isOneToOne: false
            referencedRelation: "document_representation"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "document_summary_scope_node_id_fkey"
            columns: ["scope_node_id"]
            isOneToOne: false
            referencedRelation: "document_node"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "document_summary_supersedes_id_fkey"
            columns: ["supersedes_id"]
            isOneToOne: false
            referencedRelation: "document_summary"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "document_summary_tenant_id_derived_from_representation_id_fkey"
            columns: ["tenant_id", "derived_from_representation_id"]
            isOneToOne: false
            referencedRelation: "document_representation"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "document_summary_tenant_id_document_version_id_fkey"
            columns: ["tenant_id", "document_version_id"]
            isOneToOne: false
            referencedRelation: "document_version"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "document_summary_tenant_id_representation_id_fkey"
            columns: ["tenant_id", "representation_id"]
            isOneToOne: false
            referencedRelation: "document_representation"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "document_summary_tenant_id_scope_node_id_fkey"
            columns: ["tenant_id", "scope_node_id"]
            isOneToOne: false
            referencedRelation: "document_node"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "document_summary_tenant_id_supersedes_id_fkey"
            columns: ["tenant_id", "supersedes_id"]
            isOneToOne: false
            referencedRelation: "document_summary"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "document_summary_tenant_id_transformation_run_id_fkey"
            columns: ["tenant_id", "transformation_run_id"]
            isOneToOne: false
            referencedRelation: "transformation_run"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "document_summary_transformation_run_id_fkey"
            columns: ["transformation_run_id"]
            isOneToOne: false
            referencedRelation: "transformation_run"
            referencedColumns: ["id"]
          },
        ]
      }
      document_summary_source: {
        Row: {
          node_id: string
          summary_id: string
          tenant_id: string
          weight: number
        }
        Insert: {
          node_id: string
          summary_id: string
          tenant_id?: string
          weight?: number
        }
        Update: {
          node_id?: string
          summary_id?: string
          tenant_id?: string
          weight?: number
        }
        Relationships: [
          {
            foreignKeyName: "document_summary_source_node_id_fkey"
            columns: ["node_id"]
            isOneToOne: false
            referencedRelation: "document_node"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "document_summary_source_summary_id_fkey"
            columns: ["summary_id"]
            isOneToOne: false
            referencedRelation: "document_summary"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "document_summary_source_tenant_id_node_id_fkey"
            columns: ["tenant_id", "node_id"]
            isOneToOne: false
            referencedRelation: "document_node"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "document_summary_source_tenant_id_summary_id_fkey"
            columns: ["tenant_id", "summary_id"]
            isOneToOne: false
            referencedRelation: "document_summary"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      document_type: {
        Row: {
          axis_note: string | null
          code: string
          default_chunking_slug: string
          default_extraction_kinds: string[]
          default_spaces: string[]
          default_summary_kinds: string[]
          description: string
          family: string
          is_primary_source: boolean
          promoted_from_census: boolean
          published_at_is_world_time: boolean
          status: string
          work_entity_kind: string | null
        }
        Insert: {
          axis_note?: string | null
          code: string
          default_chunking_slug: string
          default_extraction_kinds: string[]
          default_spaces: string[]
          default_summary_kinds?: string[]
          description: string
          family: string
          is_primary_source: boolean
          promoted_from_census?: boolean
          published_at_is_world_time?: boolean
          status?: string
          work_entity_kind?: string | null
        }
        Update: {
          axis_note?: string | null
          code?: string
          default_chunking_slug?: string
          default_extraction_kinds?: string[]
          default_spaces?: string[]
          default_summary_kinds?: string[]
          description?: string
          family?: string
          is_primary_source?: boolean
          promoted_from_census?: boolean
          published_at_is_world_time?: boolean
          status?: string
          work_entity_kind?: string | null
        }
        Relationships: []
      }
      document_version: {
        Row: {
          correction_state: string
          created_at: string
          document_id: string
          effective_from: string | null
          format_code: string | null
          id: string
          manifest_sha256: string
          published_at: string | null
          resolved_revision: string | null
          supersedes_id: string | null
          tenant_id: string
          version_label: string
        }
        Insert: {
          correction_state?: string
          created_at?: string
          document_id: string
          effective_from?: string | null
          format_code?: string | null
          id?: string
          manifest_sha256: string
          published_at?: string | null
          resolved_revision?: string | null
          supersedes_id?: string | null
          tenant_id?: string
          version_label: string
        }
        Update: {
          correction_state?: string
          created_at?: string
          document_id?: string
          effective_from?: string | null
          format_code?: string | null
          id?: string
          manifest_sha256?: string
          published_at?: string | null
          resolved_revision?: string | null
          supersedes_id?: string | null
          tenant_id?: string
          version_label?: string
        }
        Relationships: [
          {
            foreignKeyName: "document_version_format_code_fkey"
            columns: ["format_code"]
            isOneToOne: false
            referencedRelation: "format"
            referencedColumns: ["code"]
          },
          {
            foreignKeyName: "document_version_tenant_id_document_id_fkey"
            columns: ["tenant_id", "document_id"]
            isOneToOne: false
            referencedRelation: "document"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "document_version_tenant_id_supersedes_id_fkey"
            columns: ["tenant_id", "supersedes_id"]
            isOneToOne: false
            referencedRelation: "document_version"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      document_version_source_capture: {
        Row: {
          capture_role: string
          created_at: string
          document_version_id: string
          identity_confidence: number
          resolution_evidence: Json
          source_capture_id: string
          tenant_id: string
        }
        Insert: {
          capture_role?: string
          created_at?: string
          document_version_id: string
          identity_confidence: number
          resolution_evidence?: Json
          source_capture_id: string
          tenant_id?: string
        }
        Update: {
          capture_role?: string
          created_at?: string
          document_version_id?: string
          identity_confidence?: number
          resolution_evidence?: Json
          source_capture_id?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "document_version_source_captu_tenant_id_document_version_i_fkey"
            columns: ["tenant_id", "document_version_id"]
            isOneToOne: false
            referencedRelation: "document_version"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      format: {
        Row: {
          code: string
          default_locator_kinds: string[]
          description: string
        }
        Insert: {
          code: string
          default_locator_kinds?: string[]
          description: string
        }
        Update: {
          code?: string
          default_locator_kinds?: string[]
          description?: string
        }
        Relationships: []
      }
      refresh_check: {
        Row: {
          checked_at: string
          content_sha256: string | null
          document_id: string
          fetch_id: string | null
          id: string
          new_version_id: string | null
          outcome: string
          prior_version_id: string
          tenant_id: string
        }
        Insert: {
          checked_at?: string
          content_sha256?: string | null
          document_id: string
          fetch_id?: string | null
          id?: string
          new_version_id?: string | null
          outcome: string
          prior_version_id: string
          tenant_id?: string
        }
        Update: {
          checked_at?: string
          content_sha256?: string | null
          document_id?: string
          fetch_id?: string | null
          id?: string
          new_version_id?: string | null
          outcome?: string
          prior_version_id?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "refresh_check_tenant_id_document_id_fkey"
            columns: ["tenant_id", "document_id"]
            isOneToOne: false
            referencedRelation: "document"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "refresh_check_tenant_id_new_version_id_fkey"
            columns: ["tenant_id", "new_version_id"]
            isOneToOne: false
            referencedRelation: "document_version"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "refresh_check_tenant_id_prior_version_id_fkey"
            columns: ["tenant_id", "prior_version_id"]
            isOneToOne: false
            referencedRelation: "document_version"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      representation_decision: {
        Row: {
          conversion_evaluation_id: string | null
          created_at: string
          decision: string
          decision_operation_id: string | null
          expires_at: string | null
          guarded_sha256: string
          id: string
          knowledge_review_decision_id: string | null
          legacy_provenance: boolean
          policy_version: string
          rationale: string
          representation_id: string
          reviewer_identity: string
          tenant_id: string
        }
        Insert: {
          conversion_evaluation_id?: string | null
          created_at?: string
          decision: string
          decision_operation_id?: string | null
          expires_at?: string | null
          guarded_sha256: string
          id?: string
          knowledge_review_decision_id?: string | null
          legacy_provenance?: boolean
          policy_version: string
          rationale: string
          representation_id: string
          reviewer_identity: string
          tenant_id?: string
        }
        Update: {
          conversion_evaluation_id?: string | null
          created_at?: string
          decision?: string
          decision_operation_id?: string | null
          expires_at?: string | null
          guarded_sha256?: string
          id?: string
          knowledge_review_decision_id?: string | null
          legacy_provenance?: boolean
          policy_version?: string
          rationale?: string
          representation_id?: string
          reviewer_identity?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "representation_decision_tenant_id_conversion_evaluation_id_fkey"
            columns: ["tenant_id", "conversion_evaluation_id"]
            isOneToOne: false
            referencedRelation: "conversion_evaluation"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "representation_decision_tenant_id_representation_id_fkey"
            columns: ["tenant_id", "representation_id"]
            isOneToOne: false
            referencedRelation: "document_representation"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      source_role: {
        Row: {
          authority_rank: number
          code: string
          default_source_tier: number
          description: string
        }
        Insert: {
          authority_rank: number
          code: string
          default_source_tier: number
          description: string
        }
        Update: {
          authority_rank?: number
          code?: string
          default_source_tier?: number
          description?: string
        }
        Relationships: []
      }
      structure_census: {
        Row: {
          census_version: string
          counts: Json
          created_at: string
          digest: string
          format_code: string
          id: string
          language: string | null
          representation_id: string
          signatures: Json
          tenant_id: string
        }
        Insert: {
          census_version: string
          counts: Json
          created_at?: string
          digest: string
          format_code: string
          id?: string
          language?: string | null
          representation_id: string
          signatures?: Json
          tenant_id?: string
        }
        Update: {
          census_version?: string
          counts?: Json
          created_at?: string
          digest?: string
          format_code?: string
          id?: string
          language?: string | null
          representation_id?: string
          signatures?: Json
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "structure_census_format_code_fkey"
            columns: ["format_code"]
            isOneToOne: false
            referencedRelation: "format"
            referencedColumns: ["code"]
          },
          {
            foreignKeyName: "structure_census_tenant_id_representation_id_fkey"
            columns: ["tenant_id", "representation_id"]
            isOneToOne: false
            referencedRelation: "document_representation"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      transformation_input: {
        Row: {
          artifact_id: string | null
          created_at: string
          ordinal: number
          representation_id: string | null
          role: string
          source_capture_id: string | null
          tenant_id: string
          transformation_run_id: string
        }
        Insert: {
          artifact_id?: string | null
          created_at?: string
          ordinal: number
          representation_id?: string | null
          role: string
          source_capture_id?: string | null
          tenant_id?: string
          transformation_run_id: string
        }
        Update: {
          artifact_id?: string | null
          created_at?: string
          ordinal?: number
          representation_id?: string | null
          role?: string
          source_capture_id?: string | null
          tenant_id?: string
          transformation_run_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "transformation_input_tenant_id_representation_id_fkey"
            columns: ["tenant_id", "representation_id"]
            isOneToOne: false
            referencedRelation: "document_representation"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "transformation_input_tenant_id_transformation_run_id_fkey"
            columns: ["tenant_id", "transformation_run_id"]
            isOneToOne: false
            referencedRelation: "transformation_run"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      transformation_kind: {
        Row: {
          code: string
          description: string
        }
        Insert: {
          code: string
          description: string
        }
        Update: {
          code?: string
          description?: string
        }
        Relationships: []
      }
      transformation_output: {
        Row: {
          artifact_id: string | null
          created_at: string
          ordinal: number
          representation_id: string | null
          role: string
          tenant_id: string
          transformation_run_id: string
        }
        Insert: {
          artifact_id?: string | null
          created_at?: string
          ordinal: number
          representation_id?: string | null
          role: string
          tenant_id?: string
          transformation_run_id: string
        }
        Update: {
          artifact_id?: string | null
          created_at?: string
          ordinal?: number
          representation_id?: string | null
          role?: string
          tenant_id?: string
          transformation_run_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "transformation_output_tenant_id_representation_id_fkey"
            columns: ["tenant_id", "representation_id"]
            isOneToOne: false
            referencedRelation: "document_representation"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "transformation_output_tenant_id_transformation_run_id_fkey"
            columns: ["tenant_id", "transformation_run_id"]
            isOneToOne: false
            referencedRelation: "transformation_run"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      transformation_run: {
        Row: {
          attempt_id: string | null
          capability_version_id: string | null
          code_ref: string | null
          contract_version: string
          converter_identity: string | null
          converter_version: string | null
          cost_usd: number | null
          created_at: string
          ended_at: string | null
          environment_sha256: string | null
          failure_class: string | null
          id: string
          idempotency_key: string
          input_manifest_sha256: string | null
          model_identity: string | null
          operation_id: string | null
          output_manifest_sha256: string | null
          package_lock_sha256: string | null
          parameters: Json
          parameters_sha256: string
          provider_route: string | null
          receipt: Json | null
          resource_observations: Json
          started_at: string | null
          status: string
          tenant_id: string
          transformation_kind: string
        }
        Insert: {
          attempt_id?: string | null
          capability_version_id?: string | null
          code_ref?: string | null
          contract_version: string
          converter_identity?: string | null
          converter_version?: string | null
          cost_usd?: number | null
          created_at?: string
          ended_at?: string | null
          environment_sha256?: string | null
          failure_class?: string | null
          id?: string
          idempotency_key: string
          input_manifest_sha256?: string | null
          model_identity?: string | null
          operation_id?: string | null
          output_manifest_sha256?: string | null
          package_lock_sha256?: string | null
          parameters?: Json
          parameters_sha256: string
          provider_route?: string | null
          receipt?: Json | null
          resource_observations?: Json
          started_at?: string | null
          status?: string
          tenant_id?: string
          transformation_kind: string
        }
        Update: {
          attempt_id?: string | null
          capability_version_id?: string | null
          code_ref?: string | null
          contract_version?: string
          converter_identity?: string | null
          converter_version?: string | null
          cost_usd?: number | null
          created_at?: string
          ended_at?: string | null
          environment_sha256?: string | null
          failure_class?: string | null
          id?: string
          idempotency_key?: string
          input_manifest_sha256?: string | null
          model_identity?: string | null
          operation_id?: string | null
          output_manifest_sha256?: string | null
          package_lock_sha256?: string | null
          parameters?: Json
          parameters_sha256?: string
          provider_route?: string | null
          receipt?: Json | null
          resource_observations?: Json
          started_at?: string | null
          status?: string
          tenant_id?: string
          transformation_kind?: string
        }
        Relationships: [
          {
            foreignKeyName: "transformation_run_transformation_kind_fkey"
            columns: ["transformation_kind"]
            isOneToOne: false
            referencedRelation: "transformation_kind"
            referencedColumns: ["code"]
          },
        ]
      }
      unit_assertion_mapping: {
        Row: {
          description: string
          deterministic: boolean
          document_type_code: string | null
          event_kind: string | null
          id: string
          qualifier_template: Json
          relationship_kind: string | null
          risk_floor: string
          source_role_code: string | null
          status: string
          stream_kind: string | null
          subject_template: Json
          target_kind: string
          time_template: Json
          unit_kind: string
          unit_kind_version: number
          value_template: Json
        }
        Insert: {
          description: string
          deterministic?: boolean
          document_type_code?: string | null
          event_kind?: string | null
          id?: string
          qualifier_template?: Json
          relationship_kind?: string | null
          risk_floor?: string
          source_role_code?: string | null
          status?: string
          stream_kind?: string | null
          subject_template: Json
          target_kind: string
          time_template?: Json
          unit_kind: string
          unit_kind_version?: number
          value_template?: Json
        }
        Update: {
          description?: string
          deterministic?: boolean
          document_type_code?: string | null
          event_kind?: string | null
          id?: string
          qualifier_template?: Json
          relationship_kind?: string | null
          risk_floor?: string
          source_role_code?: string | null
          status?: string
          stream_kind?: string | null
          subject_template?: Json
          target_kind?: string
          time_template?: Json
          unit_kind?: string
          unit_kind_version?: number
          value_template?: Json
        }
        Relationships: [
          {
            foreignKeyName: "unit_assertion_mapping_document_type_code_fkey"
            columns: ["document_type_code"]
            isOneToOne: false
            referencedRelation: "document_type"
            referencedColumns: ["code"]
          },
          {
            foreignKeyName: "unit_assertion_mapping_source_role_code_fkey"
            columns: ["source_role_code"]
            isOneToOne: false
            referencedRelation: "source_role"
            referencedColumns: ["code"]
          },
          {
            foreignKeyName: "unit_assertion_mapping_unit_kind_unit_kind_version_fkey"
            columns: ["unit_kind", "unit_kind_version"]
            isOneToOne: false
            referencedRelation: "unit_kind"
            referencedColumns: ["code", "version"]
          },
        ]
      }
      unit_change: {
        Row: {
          change_kind: string
          changed_attributes: Json
          detected_at: string
          document_id: string
          from_node_id: string | null
          from_version_id: string | null
          id: string
          logical_key: string
          refresh_check_id: string | null
          tenant_id: string
          to_node_id: string | null
          to_version_id: string
          unit_kind: string
          update_proposal_state: string
        }
        Insert: {
          change_kind: string
          changed_attributes?: Json
          detected_at?: string
          document_id: string
          from_node_id?: string | null
          from_version_id?: string | null
          id?: string
          logical_key: string
          refresh_check_id?: string | null
          tenant_id?: string
          to_node_id?: string | null
          to_version_id: string
          unit_kind: string
          update_proposal_state?: string
        }
        Update: {
          change_kind?: string
          changed_attributes?: Json
          detected_at?: string
          document_id?: string
          from_node_id?: string | null
          from_version_id?: string | null
          id?: string
          logical_key?: string
          refresh_check_id?: string | null
          tenant_id?: string
          to_node_id?: string | null
          to_version_id?: string
          unit_kind?: string
          update_proposal_state?: string
        }
        Relationships: [
          {
            foreignKeyName: "unit_change_refresh_check_id_fkey"
            columns: ["refresh_check_id"]
            isOneToOne: false
            referencedRelation: "refresh_check"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "unit_change_tenant_id_document_id_fkey"
            columns: ["tenant_id", "document_id"]
            isOneToOne: false
            referencedRelation: "document"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "unit_change_tenant_id_from_node_id_fkey"
            columns: ["tenant_id", "from_node_id"]
            isOneToOne: false
            referencedRelation: "document_node"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "unit_change_tenant_id_to_node_id_fkey"
            columns: ["tenant_id", "to_node_id"]
            isOneToOne: false
            referencedRelation: "document_node"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "unit_change_tenant_id_to_version_id_fkey"
            columns: ["tenant_id", "to_version_id"]
            isOneToOne: false
            referencedRelation: "document_version"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      unit_entity_role: {
        Row: {
          claim_id: string | null
          confidence: number | null
          created_at: string
          entity_id: string
          method: string
          node_id: string
          role: string
          tenant_id: string
        }
        Insert: {
          claim_id?: string | null
          confidence?: number | null
          created_at?: string
          entity_id: string
          method: string
          node_id: string
          role: string
          tenant_id?: string
        }
        Update: {
          claim_id?: string | null
          confidence?: number | null
          created_at?: string
          entity_id?: string
          method?: string
          node_id?: string
          role?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "unit_entity_role_tenant_id_node_id_fkey"
            columns: ["tenant_id", "node_id"]
            isOneToOne: false
            referencedRelation: "document_node"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      unit_kind: {
        Row: {
          applicable_document_types: string[] | null
          attributes_schema: Json
          code: string
          description: string
          entity_roles: string[]
          is_universal: boolean
          logical_key_attributes: string[]
          parent_kinds: string[] | null
          retrieval_role: string
          selector_kind: string
          status: string
          version: number
        }
        Insert: {
          applicable_document_types?: string[] | null
          attributes_schema?: Json
          code: string
          description: string
          entity_roles?: string[]
          is_universal?: boolean
          logical_key_attributes?: string[]
          parent_kinds?: string[] | null
          retrieval_role?: string
          selector_kind: string
          status?: string
          version?: number
        }
        Update: {
          applicable_document_types?: string[] | null
          attributes_schema?: Json
          code?: string
          description?: string
          entity_roles?: string[]
          is_universal?: boolean
          logical_key_attributes?: string[]
          parent_kinds?: string[] | null
          retrieval_role?: string
          selector_kind?: string
          status?: string
          version?: number
        }
        Relationships: []
      }
      unit_link: {
        Row: {
          confidence: number
          created_at: string
          from_node_id: string
          kind: string
          method: string
          tenant_id: string
          to_node_id: string
        }
        Insert: {
          confidence?: number
          created_at?: string
          from_node_id: string
          kind: string
          method?: string
          tenant_id?: string
          to_node_id: string
        }
        Update: {
          confidence?: number
          created_at?: string
          from_node_id?: string
          kind?: string
          method?: string
          tenant_id?: string
          to_node_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "unit_link_from_node_id_fkey"
            columns: ["from_node_id"]
            isOneToOne: false
            referencedRelation: "document_node"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "unit_link_to_node_id_fkey"
            columns: ["to_node_id"]
            isOneToOne: false
            referencedRelation: "document_node"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      current_kind: { Args: { p_document: string }; Returns: string }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  conversation: {
    Tables: {
      context_item: {
        Row: {
          artifact_id: string | null
          id: string
          item_key: string
          offer_id: string | null
          part_id: string | null
          passage_id: string | null
          reason: string
          release_item_id: string | null
          revision_id: string | null
          snapshot_id: string
          tenant_id: string
          workspace_id: string
        }
        Insert: {
          artifact_id?: string | null
          id?: string
          item_key: string
          offer_id?: string | null
          part_id?: string | null
          passage_id?: string | null
          reason: string
          release_item_id?: string | null
          revision_id?: string | null
          snapshot_id: string
          tenant_id: string
          workspace_id: string
        }
        Update: {
          artifact_id?: string | null
          id?: string
          item_key?: string
          offer_id?: string | null
          part_id?: string | null
          passage_id?: string | null
          reason?: string
          release_item_id?: string | null
          revision_id?: string | null
          snapshot_id?: string
          tenant_id?: string
          workspace_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "context_item_tenant_id_workspace_id_snapshot_id_fkey"
            columns: ["tenant_id", "workspace_id", "snapshot_id"]
            isOneToOne: false
            referencedRelation: "context_snapshot"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
        ]
      }
      context_snapshot: {
        Row: {
          body: Json
          created_at: string
          digest: string
          id: string
          tenant_id: string
          workspace_id: string
        }
        Insert: {
          body: Json
          created_at?: string
          digest: string
          id?: string
          tenant_id: string
          workspace_id: string
        }
        Update: {
          body?: Json
          created_at?: string
          digest?: string
          id?: string
          tenant_id?: string
          workspace_id?: string
        }
        Relationships: []
      }
      message: {
        Row: {
          agent_identity: string | null
          author_id: string | null
          client_surface: string
          content: Json
          content_sha256: string
          context_snapshot_id: string | null
          created_at: string
          id: string
          redacted_at: string | null
          redacted_by_removal_id: string | null
          role: string
          runtime_ref: Json
          seq: number
          tenant_id: string
          thread_id: string
          usage: Json
          workspace_id: string
        }
        Insert: {
          agent_identity?: string | null
          author_id?: string | null
          client_surface: string
          content: Json
          content_sha256: string
          context_snapshot_id?: string | null
          created_at?: string
          id?: string
          redacted_at?: string | null
          redacted_by_removal_id?: string | null
          role: string
          runtime_ref?: Json
          seq: number
          tenant_id: string
          thread_id: string
          usage?: Json
          workspace_id: string
        }
        Update: {
          agent_identity?: string | null
          author_id?: string | null
          client_surface?: string
          content?: Json
          content_sha256?: string
          context_snapshot_id?: string | null
          created_at?: string
          id?: string
          redacted_at?: string | null
          redacted_by_removal_id?: string | null
          role?: string
          runtime_ref?: Json
          seq?: number
          tenant_id?: string
          thread_id?: string
          usage?: Json
          workspace_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "message_tenant_id_workspace_id_context_snapshot_id_fkey"
            columns: ["tenant_id", "workspace_id", "context_snapshot_id"]
            isOneToOne: false
            referencedRelation: "context_snapshot"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
          {
            foreignKeyName: "message_tenant_id_workspace_id_thread_id_fkey"
            columns: ["tenant_id", "workspace_id", "thread_id"]
            isOneToOne: false
            referencedRelation: "thread"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
        ]
      }
      thread: {
        Row: {
          archived_at: string | null
          created_at: string
          id: string
          imported_from: Json | null
          mode: string
          origin: string
          owner_id: string
          purpose: string
          tenant_id: string
          title: string
          visibility: string
          workspace_id: string
        }
        Insert: {
          archived_at?: string | null
          created_at?: string
          id?: string
          imported_from?: Json | null
          mode?: string
          origin?: string
          owner_id: string
          purpose: string
          tenant_id: string
          title: string
          visibility?: string
          workspace_id: string
        }
        Update: {
          archived_at?: string | null
          created_at?: string
          id?: string
          imported_from?: Json | null
          mode?: string
          origin?: string
          owner_id?: string
          purpose?: string
          tenant_id?: string
          title?: string
          visibility?: string
          workspace_id?: string
        }
        Relationships: []
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  curriculum: {
    Tables: {
      outcome: {
        Row: {
          bloom_level: string | null
          created_at: string
          evidence_rule: Json
          id: string
          outcome_key: string
          revision_id: string
          statement: string
          tenant_id: string
          workspace_id: string
        }
        Insert: {
          bloom_level?: string | null
          created_at?: string
          evidence_rule: Json
          id?: string
          outcome_key: string
          revision_id: string
          statement: string
          tenant_id: string
          workspace_id: string
        }
        Update: {
          bloom_level?: string | null
          created_at?: string
          evidence_rule?: Json
          id?: string
          outcome_key?: string
          revision_id?: string
          statement?: string
          tenant_id?: string
          workspace_id?: string
        }
        Relationships: []
      }
      outcome_alignment: {
        Row: {
          competency_revision_id: string
          coverage: string
          created_at: string
          facet: string
          id: string
          outcome_id: string
          rationale: string
          tenant_id: string
          workspace_id: string
        }
        Insert: {
          competency_revision_id: string
          coverage: string
          created_at?: string
          facet: string
          id?: string
          outcome_id: string
          rationale: string
          tenant_id: string
          workspace_id: string
        }
        Update: {
          competency_revision_id?: string
          coverage?: string
          created_at?: string
          facet?: string
          id?: string
          outcome_id?: string
          rationale?: string
          tenant_id?: string
          workspace_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "outcome_alignment_tenant_id_workspace_id_outcome_id_fkey"
            columns: ["tenant_id", "workspace_id", "outcome_id"]
            isOneToOne: false
            referencedRelation: "outcome"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
        ]
      }
      part: {
        Row: {
          child_revision_id: string
          created_at: string
          id: string
          occurrence_key: string
          ordinal: number
          parent_revision_id: string
          role: string
          tenant_id: string
          workspace_id: string
        }
        Insert: {
          child_revision_id: string
          created_at?: string
          id?: string
          occurrence_key: string
          ordinal: number
          parent_revision_id: string
          role: string
          tenant_id: string
          workspace_id: string
        }
        Update: {
          child_revision_id?: string
          created_at?: string
          id?: string
          occurrence_key?: string
          ordinal?: number
          parent_revision_id?: string
          role?: string
          tenant_id?: string
          workspace_id?: string
        }
        Relationships: []
      }
      prerequisite: {
        Row: {
          created_at: string
          id: string
          rationale: string
          required_revision_id: string
          revision_id: string
          strength: string
          tenant_id: string
          workspace_id: string
        }
        Insert: {
          created_at?: string
          id?: string
          rationale: string
          required_revision_id: string
          revision_id: string
          strength: string
          tenant_id: string
          workspace_id: string
        }
        Update: {
          created_at?: string
          id?: string
          rationale?: string
          required_revision_id?: string
          revision_id?: string
          strength?: string
          tenant_id?: string
          workspace_id?: string
        }
        Relationships: []
      }
      release_transition: {
        Row: {
          compatibility: string
          created_at: string
          from_release_id: string
          id: string
          mapping: Json
          mapping_schema: string
          reviewed_event_id: string | null
          tenant_id: string
          to_release_id: string
          workspace_id: string
        }
        Insert: {
          compatibility: string
          created_at?: string
          from_release_id: string
          id?: string
          mapping: Json
          mapping_schema: string
          reviewed_event_id?: string | null
          tenant_id: string
          to_release_id: string
          workspace_id: string
        }
        Update: {
          compatibility?: string
          created_at?: string
          from_release_id?: string
          id?: string
          mapping?: Json
          mapping_schema?: string
          reviewed_event_id?: string | null
          tenant_id?: string
          to_release_id?: string
          workspace_id?: string
        }
        Relationships: []
      }
      requirement: {
        Row: {
          created_at: string
          id: string
          kind: string
          outcome_id: string | null
          part_id: string | null
          rationale: string
          requirement_key: string
          revision_id: string
          tenant_id: string
          workspace_id: string
        }
        Insert: {
          created_at?: string
          id?: string
          kind: string
          outcome_id?: string | null
          part_id?: string | null
          rationale: string
          requirement_key: string
          revision_id: string
          tenant_id: string
          workspace_id: string
        }
        Update: {
          created_at?: string
          id?: string
          kind?: string
          outcome_id?: string | null
          part_id?: string | null
          rationale?: string
          requirement_key?: string
          revision_id?: string
          tenant_id?: string
          workspace_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "requirement_tenant_id_workspace_id_part_id_fkey"
            columns: ["tenant_id", "workspace_id", "part_id"]
            isOneToOne: false
            referencedRelation: "part"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
          {
            foreignKeyName: "requirement_tenant_id_workspace_id_revision_id_outcome_id_fkey"
            columns: ["tenant_id", "workspace_id", "revision_id", "outcome_id"]
            isOneToOne: false
            referencedRelation: "outcome"
            referencedColumns: [
              "tenant_id",
              "workspace_id",
              "revision_id",
              "id",
            ]
          },
        ]
      }
      requirement_option: {
        Row: {
          activity_revision_id: string | null
          approval_state: string
          approved_by: string | null
          created_at: string
          evidence_rule: Json
          id: string
          requirement_id: string
          route: string
          tenant_id: string
          workspace_id: string
        }
        Insert: {
          activity_revision_id?: string | null
          approval_state: string
          approved_by?: string | null
          created_at?: string
          evidence_rule: Json
          id?: string
          requirement_id: string
          route: string
          tenant_id: string
          workspace_id: string
        }
        Update: {
          activity_revision_id?: string | null
          approval_state?: string
          approved_by?: string | null
          created_at?: string
          evidence_rule?: Json
          id?: string
          requirement_id?: string
          route?: string
          tenant_id?: string
          workspace_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "requirement_option_tenant_id_workspace_id_requirement_id_fkey"
            columns: ["tenant_id", "workspace_id", "requirement_id"]
            isOneToOne: false
            referencedRelation: "requirement"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
        ]
      }
      requirement_transition: {
        Row: {
          carry: string
          created_at: string
          effect: string
          from_requirement_id: string | null
          id: string
          rationale: string
          tenant_id: string
          to_requirement_id: string | null
          transition_id: string
          workspace_id: string
        }
        Insert: {
          carry: string
          created_at?: string
          effect: string
          from_requirement_id?: string | null
          id?: string
          rationale: string
          tenant_id: string
          to_requirement_id?: string | null
          transition_id: string
          workspace_id: string
        }
        Update: {
          carry?: string
          created_at?: string
          effect?: string
          from_requirement_id?: string | null
          id?: string
          rationale?: string
          tenant_id?: string
          to_requirement_id?: string | null
          transition_id?: string
          workspace_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "requirement_transition_tenant_id_workspace_id_from_require_fkey"
            columns: ["tenant_id", "workspace_id", "from_requirement_id"]
            isOneToOne: false
            referencedRelation: "requirement"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
          {
            foreignKeyName: "requirement_transition_tenant_id_workspace_id_to_requireme_fkey"
            columns: ["tenant_id", "workspace_id", "to_requirement_id"]
            isOneToOne: false
            referencedRelation: "requirement"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
          {
            foreignKeyName: "requirement_transition_tenant_id_workspace_id_transition_i_fkey"
            columns: ["tenant_id", "workspace_id", "transition_id"]
            isOneToOne: false
            referencedRelation: "release_transition"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  dataset: {
    Tables: {
      cell: {
        Row: {
          created_at: string
          dataset_kind: string
          dataset_work_id: string
          entered_by: string
          entered_kind: string
          entered_origin_ref: Json
          field_key: string
          from_revision_no: number | null
          id: string
          observed_at: string | null
          proposal_id: string | null
          row_key: string
          tenant_id: string
          to_revision_no: number | null
          value: Json | null
          value_status: string
          workspace_id: string
        }
        Insert: {
          created_at?: string
          dataset_kind?: string
          dataset_work_id: string
          entered_by: string
          entered_kind: string
          entered_origin_ref?: Json
          field_key: string
          from_revision_no?: number | null
          id?: string
          observed_at?: string | null
          proposal_id?: string | null
          row_key: string
          tenant_id: string
          to_revision_no?: number | null
          value?: Json | null
          value_status: string
          workspace_id: string
        }
        Update: {
          created_at?: string
          dataset_kind?: string
          dataset_work_id?: string
          entered_by?: string
          entered_kind?: string
          entered_origin_ref?: Json
          field_key?: string
          from_revision_no?: number | null
          id?: string
          observed_at?: string | null
          proposal_id?: string | null
          row_key?: string
          tenant_id?: string
          to_revision_no?: number | null
          value?: Json | null
          value_status?: string
          workspace_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "cell_tenant_id_workspace_id_proposal_id_fkey"
            columns: ["tenant_id", "workspace_id", "proposal_id"]
            isOneToOne: false
            referencedRelation: "proposal"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
        ]
      }
      field: {
        Row: {
          created_at: string
          currency: string | null
          dataset_kind: string
          dataset_work_id: string
          entered_by: string
          field_key: string
          from_revision_no: number
          id: string
          meaning: string
          name: string
          position: number
          required: boolean
          tenant_id: string
          to_revision_no: number | null
          unit: string | null
          value_type: string
          workspace_id: string
        }
        Insert: {
          created_at?: string
          currency?: string | null
          dataset_kind?: string
          dataset_work_id: string
          entered_by: string
          field_key: string
          from_revision_no: number
          id?: string
          meaning: string
          name: string
          position: number
          required?: boolean
          tenant_id: string
          to_revision_no?: number | null
          unit?: string | null
          value_type: string
          workspace_id: string
        }
        Update: {
          created_at?: string
          currency?: string | null
          dataset_kind?: string
          dataset_work_id?: string
          entered_by?: string
          field_key?: string
          from_revision_no?: number
          id?: string
          meaning?: string
          name?: string
          position?: number
          required?: boolean
          tenant_id?: string
          to_revision_no?: number | null
          unit?: string | null
          value_type?: string
          workspace_id?: string
        }
        Relationships: []
      }
      proposal: {
        Row: {
          acceptance_id: string | null
          applied_revision_id: string | null
          base_revision_no: number
          created_at: string
          created_by: string
          created_kind: string
          dataset_kind: string
          dataset_work_id: string
          decided_at: string | null
          decided_by: string | null
          dedupe_key: string
          id: string
          reason: string
          state: string
          summary: Json
          tenant_id: string
          workspace_id: string
        }
        Insert: {
          acceptance_id?: string | null
          applied_revision_id?: string | null
          base_revision_no: number
          created_at?: string
          created_by: string
          created_kind: string
          dataset_kind?: string
          dataset_work_id: string
          decided_at?: string | null
          decided_by?: string | null
          dedupe_key: string
          id?: string
          reason: string
          state?: string
          summary: Json
          tenant_id: string
          workspace_id: string
        }
        Update: {
          acceptance_id?: string | null
          applied_revision_id?: string | null
          base_revision_no?: number
          created_at?: string
          created_by?: string
          created_kind?: string
          dataset_kind?: string
          dataset_work_id?: string
          decided_at?: string | null
          decided_by?: string | null
          dedupe_key?: string
          id?: string
          reason?: string
          state?: string
          summary?: Json
          tenant_id?: string
          workspace_id?: string
        }
        Relationships: []
      }
      row: {
        Row: {
          created_at: string
          dataset_kind: string
          dataset_work_id: string
          entered_by: string
          entity_id: string | null
          from_revision_no: number | null
          id: string
          label: string | null
          position: number
          proposal_id: string | null
          row_key: string
          tenant_id: string
          to_revision_no: number | null
          workspace_id: string
        }
        Insert: {
          created_at?: string
          dataset_kind?: string
          dataset_work_id: string
          entered_by: string
          entity_id?: string | null
          from_revision_no?: number | null
          id?: string
          label?: string | null
          position: number
          proposal_id?: string | null
          row_key: string
          tenant_id: string
          to_revision_no?: number | null
          workspace_id: string
        }
        Update: {
          created_at?: string
          dataset_kind?: string
          dataset_work_id?: string
          entered_by?: string
          entity_id?: string | null
          from_revision_no?: number | null
          id?: string
          label?: string | null
          position?: number
          proposal_id?: string | null
          row_key?: string
          tenant_id?: string
          to_revision_no?: number | null
          workspace_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "row_tenant_id_workspace_id_proposal_id_fkey"
            columns: ["tenant_id", "workspace_id", "proposal_id"]
            isOneToOne: false
            referencedRelation: "proposal"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  evaluation: {
    Tables: {
      eval_case: {
        Row: {
          case_sha256: string | null
          created_at: string
          dataset_id: string
          dataset_version_id: string | null
          expected: Json | null
          external_key: string | null
          gold_artifact_id: string | null
          id: string
          input: Json
          input_manifest_artifact_id: string | null
          metadata: Json
          tenant_id: string
          verification_contract_version: string | null
        }
        Insert: {
          case_sha256?: string | null
          created_at?: string
          dataset_id: string
          dataset_version_id?: string | null
          expected?: Json | null
          external_key?: string | null
          gold_artifact_id?: string | null
          id?: string
          input: Json
          input_manifest_artifact_id?: string | null
          metadata?: Json
          tenant_id?: string
          verification_contract_version?: string | null
        }
        Update: {
          case_sha256?: string | null
          created_at?: string
          dataset_id?: string
          dataset_version_id?: string | null
          expected?: Json | null
          external_key?: string | null
          gold_artifact_id?: string | null
          id?: string
          input?: Json
          input_manifest_artifact_id?: string | null
          metadata?: Json
          tenant_id?: string
          verification_contract_version?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "eval_case_dataset_id_fkey"
            columns: ["dataset_id"]
            isOneToOne: false
            referencedRelation: "eval_dataset"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "eval_case_tenant_dataset_fk"
            columns: ["tenant_id", "dataset_id"]
            isOneToOne: false
            referencedRelation: "eval_dataset"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "eval_case_tenant_dataset_version_fk"
            columns: ["tenant_id", "dataset_version_id"]
            isOneToOne: false
            referencedRelation: "eval_dataset_version"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      eval_case_expected_filter: {
        Row: {
          created_at: string
          eval_case_id: string
          expected_filter: Json
          filter_kind: string
          hard_constraint: boolean
          id: string
          tenant_id: string
        }
        Insert: {
          created_at?: string
          eval_case_id: string
          expected_filter: Json
          filter_kind: string
          hard_constraint?: boolean
          id?: string
          tenant_id?: string
        }
        Update: {
          created_at?: string
          eval_case_id?: string
          expected_filter?: Json
          filter_kind?: string
          hard_constraint?: boolean
          id?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "eval_case_expected_filter_tenant_id_eval_case_id_fkey"
            columns: ["tenant_id", "eval_case_id"]
            isOneToOne: false
            referencedRelation: "eval_case"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      eval_case_provenance: {
        Row: {
          artifact_id: string | null
          created_at: string
          eval_case_id: string
          id: string
          provenance: Json
          source_capture_id: string | null
          tenant_id: string
        }
        Insert: {
          artifact_id?: string | null
          created_at?: string
          eval_case_id: string
          id?: string
          provenance: Json
          source_capture_id?: string | null
          tenant_id?: string
        }
        Update: {
          artifact_id?: string | null
          created_at?: string
          eval_case_id?: string
          id?: string
          provenance?: Json
          source_capture_id?: string | null
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "eval_case_provenance_tenant_id_eval_case_id_fkey"
            columns: ["tenant_id", "eval_case_id"]
            isOneToOne: false
            referencedRelation: "eval_case"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      eval_case_relevance: {
        Row: {
          created_at: string
          eval_case_id: string
          projection_target_id: string
          rationale: string | null
          relevance_grade: number
          tenant_id: string
        }
        Insert: {
          created_at?: string
          eval_case_id: string
          projection_target_id: string
          rationale?: string | null
          relevance_grade: number
          tenant_id?: string
        }
        Update: {
          created_at?: string
          eval_case_id?: string
          projection_target_id?: string
          rationale?: string | null
          relevance_grade?: number
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "eval_case_relevance_tenant_id_eval_case_id_fkey"
            columns: ["tenant_id", "eval_case_id"]
            isOneToOne: false
            referencedRelation: "eval_case"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      eval_dataset: {
        Row: {
          created_at: string
          description: string | null
          id: string
          purpose: string
          slug: string
          tenant_id: string
        }
        Insert: {
          created_at?: string
          description?: string | null
          id?: string
          purpose: string
          slug: string
          tenant_id?: string
        }
        Update: {
          created_at?: string
          description?: string | null
          id?: string
          purpose?: string
          slug?: string
          tenant_id?: string
        }
        Relationships: []
      }
      eval_dataset_version: {
        Row: {
          case_count: number | null
          contract_version: string | null
          created_at: string
          dataset_id: string
          frozen_at: string | null
          id: string
          label_provenance: string | null
          manifest: Json
          manifest_artifact_id: string | null
          manifest_sha256: string
          tenant_id: string
          version: number
        }
        Insert: {
          case_count?: number | null
          contract_version?: string | null
          created_at?: string
          dataset_id: string
          frozen_at?: string | null
          id?: string
          label_provenance?: string | null
          manifest: Json
          manifest_artifact_id?: string | null
          manifest_sha256: string
          tenant_id?: string
          version: number
        }
        Update: {
          case_count?: number | null
          contract_version?: string | null
          created_at?: string
          dataset_id?: string
          frozen_at?: string | null
          id?: string
          label_provenance?: string | null
          manifest?: Json
          manifest_artifact_id?: string | null
          manifest_sha256?: string
          tenant_id?: string
          version?: number
        }
        Relationships: [
          {
            foreignKeyName: "eval_dataset_version_tenant_id_dataset_id_fkey"
            columns: ["tenant_id", "dataset_id"]
            isOneToOne: false
            referencedRelation: "eval_dataset"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      eval_label: {
        Row: {
          case_id: string
          created_at: string
          id: string
          label: Json
          label_artifact_id: string | null
          label_sha256: string | null
          labeled_by: string
          provenance_class: string | null
          review_decision_id: string | null
          tenant_id: string | null
          verification_contract_version: string | null
        }
        Insert: {
          case_id: string
          created_at?: string
          id?: string
          label: Json
          label_artifact_id?: string | null
          label_sha256?: string | null
          labeled_by: string
          provenance_class?: string | null
          review_decision_id?: string | null
          tenant_id?: string | null
          verification_contract_version?: string | null
        }
        Update: {
          case_id?: string
          created_at?: string
          id?: string
          label?: Json
          label_artifact_id?: string | null
          label_sha256?: string | null
          labeled_by?: string
          provenance_class?: string | null
          review_decision_id?: string | null
          tenant_id?: string | null
          verification_contract_version?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "eval_label_case_id_fkey"
            columns: ["case_id"]
            isOneToOne: false
            referencedRelation: "eval_case"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "eval_label_review_decision_fk"
            columns: ["review_decision_id"]
            isOneToOne: false
            referencedRelation: "review_decision"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "eval_label_tenant_case_fk"
            columns: ["tenant_id", "case_id"]
            isOneToOne: false
            referencedRelation: "eval_case"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      eval_run: {
        Row: {
          attempt_id: string | null
          capability_version_id: string | null
          code_ref: string | null
          config: Json
          dataset_id: string
          dataset_version_id: string | null
          ended_at: string | null
          executed_at: string
          experiment_arm_id: string | null
          grader_version_id: string | null
          id: string
          mission_id: string | null
          policy_artifact_id: string | null
          run_manifest_artifact_id: string | null
          space_version_id: string | null
          started_at: string | null
          status: string | null
          target_code_ref: string | null
          target_kind: string | null
          tenant_id: string
          verification_contract_version: string | null
          work_item_id: string | null
        }
        Insert: {
          attempt_id?: string | null
          capability_version_id?: string | null
          code_ref?: string | null
          config?: Json
          dataset_id: string
          dataset_version_id?: string | null
          ended_at?: string | null
          executed_at?: string
          experiment_arm_id?: string | null
          grader_version_id?: string | null
          id?: string
          mission_id?: string | null
          policy_artifact_id?: string | null
          run_manifest_artifact_id?: string | null
          space_version_id?: string | null
          started_at?: string | null
          status?: string | null
          target_code_ref?: string | null
          target_kind?: string | null
          tenant_id?: string
          verification_contract_version?: string | null
          work_item_id?: string | null
        }
        Update: {
          attempt_id?: string | null
          capability_version_id?: string | null
          code_ref?: string | null
          config?: Json
          dataset_id?: string
          dataset_version_id?: string | null
          ended_at?: string | null
          executed_at?: string
          experiment_arm_id?: string | null
          grader_version_id?: string | null
          id?: string
          mission_id?: string | null
          policy_artifact_id?: string | null
          run_manifest_artifact_id?: string | null
          space_version_id?: string | null
          started_at?: string | null
          status?: string | null
          target_code_ref?: string | null
          target_kind?: string | null
          tenant_id?: string
          verification_contract_version?: string | null
          work_item_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "eval_run_dataset_id_fkey"
            columns: ["dataset_id"]
            isOneToOne: false
            referencedRelation: "eval_dataset"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "eval_run_dataset_version_fk"
            columns: ["tenant_id", "dataset_version_id"]
            isOneToOne: false
            referencedRelation: "eval_dataset_version"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "eval_run_experiment_arm_fk"
            columns: ["tenant_id", "experiment_arm_id"]
            isOneToOne: false
            referencedRelation: "experiment_arm"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "eval_run_grader_version_id_fkey"
            columns: ["grader_version_id"]
            isOneToOne: false
            referencedRelation: "grader_version"
            referencedColumns: ["id"]
          },
        ]
      }
      eval_run_case_output: {
        Row: {
          answer: Json | null
          candidates: Json | null
          created_at: string
          eval_case_id: string
          eval_run_id: string
          id: string
          output_sha256: string
          packets: Json | null
          plan: Json | null
          tenant_id: string
        }
        Insert: {
          answer?: Json | null
          candidates?: Json | null
          created_at?: string
          eval_case_id: string
          eval_run_id: string
          id?: string
          output_sha256: string
          packets?: Json | null
          plan?: Json | null
          tenant_id?: string
        }
        Update: {
          answer?: Json | null
          candidates?: Json | null
          created_at?: string
          eval_case_id?: string
          eval_run_id?: string
          id?: string
          output_sha256?: string
          packets?: Json | null
          plan?: Json | null
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "eval_run_case_output_eval_case_id_fkey"
            columns: ["eval_case_id"]
            isOneToOne: false
            referencedRelation: "eval_case"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "eval_run_case_output_tenant_id_eval_run_id_fkey"
            columns: ["tenant_id", "eval_run_id"]
            isOneToOne: false
            referencedRelation: "eval_run"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      eval_score: {
        Row: {
          case_id: string
          created_at: string
          false_acceptance: boolean
          false_rejection: boolean
          id: string
          metrics: Json
          passed: boolean | null
          result_artifact_id: string | null
          result_sha256: string | null
          run_id: string
          tenant_id: string | null
          verification_contract_version: string | null
        }
        Insert: {
          case_id: string
          created_at?: string
          false_acceptance?: boolean
          false_rejection?: boolean
          id?: string
          metrics?: Json
          passed?: boolean | null
          result_artifact_id?: string | null
          result_sha256?: string | null
          run_id: string
          tenant_id?: string | null
          verification_contract_version?: string | null
        }
        Update: {
          case_id?: string
          created_at?: string
          false_acceptance?: boolean
          false_rejection?: boolean
          id?: string
          metrics?: Json
          passed?: boolean | null
          result_artifact_id?: string | null
          result_sha256?: string | null
          run_id?: string
          tenant_id?: string | null
          verification_contract_version?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "eval_score_case_id_fkey"
            columns: ["case_id"]
            isOneToOne: false
            referencedRelation: "eval_case"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "eval_score_run_id_fkey"
            columns: ["run_id"]
            isOneToOne: false
            referencedRelation: "eval_run"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "eval_score_tenant_case_fk"
            columns: ["tenant_id", "case_id"]
            isOneToOne: false
            referencedRelation: "eval_case"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "eval_score_tenant_run_fk"
            columns: ["tenant_id", "run_id"]
            isOneToOne: false
            referencedRelation: "eval_run"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      experiment: {
        Row: {
          created_at: string
          dataset_version_id: string
          hypothesis: string
          id: string
          name: string
          tenant_id: string
        }
        Insert: {
          created_at?: string
          dataset_version_id: string
          hypothesis: string
          id?: string
          name: string
          tenant_id?: string
        }
        Update: {
          created_at?: string
          dataset_version_id?: string
          hypothesis?: string
          id?: string
          name?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "experiment_tenant_id_dataset_version_id_fkey"
            columns: ["tenant_id", "dataset_version_id"]
            isOneToOne: false
            referencedRelation: "eval_dataset_version"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      experiment_arm: {
        Row: {
          configuration: Json
          configuration_artifact_id: string | null
          configuration_sha256: string | null
          created_at: string
          experiment_id: string
          id: string
          is_control: boolean
          name: string
          tenant_id: string
          verification_contract_version: string | null
        }
        Insert: {
          configuration: Json
          configuration_artifact_id?: string | null
          configuration_sha256?: string | null
          created_at?: string
          experiment_id: string
          id?: string
          is_control?: boolean
          name: string
          tenant_id?: string
          verification_contract_version?: string | null
        }
        Update: {
          configuration?: Json
          configuration_artifact_id?: string | null
          configuration_sha256?: string | null
          created_at?: string
          experiment_id?: string
          id?: string
          is_control?: boolean
          name?: string
          tenant_id?: string
          verification_contract_version?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "experiment_arm_tenant_id_experiment_id_fkey"
            columns: ["tenant_id", "experiment_id"]
            isOneToOne: false
            referencedRelation: "experiment"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      gate: {
        Row: {
          created_at: string
          id: string
          purpose: string
          slug: string
          thresholds: Json
        }
        Insert: {
          created_at?: string
          id?: string
          purpose: string
          slug: string
          thresholds?: Json
        }
        Update: {
          created_at?: string
          id?: string
          purpose?: string
          slug?: string
          thresholds?: Json
        }
        Relationships: []
      }
      gate_binding: {
        Row: {
          created_at: string
          gate_id: string
          guards_kind: string
          guards_ref: string | null
          id: string
        }
        Insert: {
          created_at?: string
          gate_id: string
          guards_kind: string
          guards_ref?: string | null
          id?: string
        }
        Update: {
          created_at?: string
          gate_id?: string
          guards_kind?: string
          guards_ref?: string | null
          id?: string
        }
        Relationships: [
          {
            foreignKeyName: "gate_binding_gate_id_fkey"
            columns: ["gate_id"]
            isOneToOne: false
            referencedRelation: "gate"
            referencedColumns: ["id"]
          },
        ]
      }
      gate_result: {
        Row: {
          action: Database["evaluation"]["Enums"]["gate_action"]
          created_at: string
          detail: Json
          eval_run_id: string | null
          gate_id: string
          id: string
          passed: boolean
          spawned_work_item_id: string | null
        }
        Insert: {
          action: Database["evaluation"]["Enums"]["gate_action"]
          created_at?: string
          detail?: Json
          eval_run_id?: string | null
          gate_id: string
          id?: string
          passed: boolean
          spawned_work_item_id?: string | null
        }
        Update: {
          action?: Database["evaluation"]["Enums"]["gate_action"]
          created_at?: string
          detail?: Json
          eval_run_id?: string | null
          gate_id?: string
          id?: string
          passed?: boolean
          spawned_work_item_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "gate_result_eval_run_id_fkey"
            columns: ["eval_run_id"]
            isOneToOne: false
            referencedRelation: "eval_run"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "gate_result_gate_id_fkey"
            columns: ["gate_id"]
            isOneToOne: false
            referencedRelation: "gate"
            referencedColumns: ["id"]
          },
        ]
      }
      grader: {
        Row: {
          created_at: string
          id: string
          kind: string
          purpose: string
          slug: string
          tenant_id: string | null
        }
        Insert: {
          created_at?: string
          id?: string
          kind: string
          purpose: string
          slug: string
          tenant_id?: string | null
        }
        Update: {
          created_at?: string
          id?: string
          kind?: string
          purpose?: string
          slug?: string
          tenant_id?: string | null
        }
        Relationships: []
      }
      grader_version: {
        Row: {
          code_ref: string | null
          config: Json
          created_at: string
          grader_id: string
          id: string
          manifest_artifact_id: string | null
          manifest_sha256: string | null
          model: string | null
          prompt: string | null
          tenant_id: string | null
          verification_contract_version: string | null
          version: number
        }
        Insert: {
          code_ref?: string | null
          config?: Json
          created_at?: string
          grader_id: string
          id?: string
          manifest_artifact_id?: string | null
          manifest_sha256?: string | null
          model?: string | null
          prompt?: string | null
          tenant_id?: string | null
          verification_contract_version?: string | null
          version: number
        }
        Update: {
          code_ref?: string | null
          config?: Json
          created_at?: string
          grader_id?: string
          id?: string
          manifest_artifact_id?: string | null
          manifest_sha256?: string | null
          model?: string | null
          prompt?: string | null
          tenant_id?: string | null
          verification_contract_version?: string | null
          version?: number
        }
        Relationships: [
          {
            foreignKeyName: "grader_version_grader_id_fkey"
            columns: ["grader_id"]
            isOneToOne: false
            referencedRelation: "grader"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "grader_version_tenant_grader_fk"
            columns: ["tenant_id", "grader_id"]
            isOneToOne: false
            referencedRelation: "grader"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      judge_output: {
        Row: {
          calibration_identity: string | null
          created_at: string
          eval_run_case_output_id: string
          grader_version_id: string
          id: string
          model_identity: string
          output: Json
          output_sha256: string
          prompt_sha256: string
          schema_version: string
          tenant_id: string
        }
        Insert: {
          calibration_identity?: string | null
          created_at?: string
          eval_run_case_output_id: string
          grader_version_id: string
          id?: string
          model_identity: string
          output: Json
          output_sha256: string
          prompt_sha256: string
          schema_version: string
          tenant_id?: string
        }
        Update: {
          calibration_identity?: string | null
          created_at?: string
          eval_run_case_output_id?: string
          grader_version_id?: string
          id?: string
          model_identity?: string
          output?: Json
          output_sha256?: string
          prompt_sha256?: string
          schema_version?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "judge_output_grader_version_id_fkey"
            columns: ["grader_version_id"]
            isOneToOne: false
            referencedRelation: "grader_version"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "judge_output_tenant_id_eval_run_case_output_id_fkey"
            columns: ["tenant_id", "eval_run_case_output_id"]
            isOneToOne: false
            referencedRelation: "eval_run_case_output"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      metric_definition: {
        Row: {
          created_at: string
          definition: Json
          id: string
          metric_kind: string
          slug: string
          tenant_id: string
          version: number
        }
        Insert: {
          created_at?: string
          definition: Json
          id?: string
          metric_kind: string
          slug: string
          tenant_id?: string
          version: number
        }
        Update: {
          created_at?: string
          definition?: Json
          id?: string
          metric_kind?: string
          slug?: string
          tenant_id?: string
          version?: number
        }
        Relationships: []
      }
      metric_observation: {
        Row: {
          created_at: string
          details: Json
          eval_case_id: string | null
          eval_run_id: string
          id: string
          metric_definition_id: string
          tenant_id: string
          value: number | null
        }
        Insert: {
          created_at?: string
          details?: Json
          eval_case_id?: string | null
          eval_run_id: string
          id?: string
          metric_definition_id: string
          tenant_id?: string
          value?: number | null
        }
        Update: {
          created_at?: string
          details?: Json
          eval_case_id?: string | null
          eval_run_id?: string
          id?: string
          metric_definition_id?: string
          tenant_id?: string
          value?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "metric_observation_eval_case_id_fkey"
            columns: ["eval_case_id"]
            isOneToOne: false
            referencedRelation: "eval_case"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "metric_observation_tenant_id_eval_run_id_fkey"
            columns: ["tenant_id", "eval_run_id"]
            isOneToOne: false
            referencedRelation: "eval_run"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "metric_observation_tenant_id_metric_definition_id_fkey"
            columns: ["tenant_id", "metric_definition_id"]
            isOneToOne: false
            referencedRelation: "metric_definition"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      promotion_gate_result: {
        Row: {
          created_at: string
          eval_run_id: string
          false_acceptance_count: number
          gate_version_id: string
          id: string
          observations: Json
          passed: boolean
          result_sha256: string
          tenant_id: string
        }
        Insert: {
          created_at?: string
          eval_run_id: string
          false_acceptance_count?: number
          gate_version_id: string
          id?: string
          observations: Json
          passed: boolean
          result_sha256: string
          tenant_id?: string
        }
        Update: {
          created_at?: string
          eval_run_id?: string
          false_acceptance_count?: number
          gate_version_id?: string
          id?: string
          observations?: Json
          passed?: boolean
          result_sha256?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "promotion_gate_result_tenant_id_eval_run_id_fkey"
            columns: ["tenant_id", "eval_run_id"]
            isOneToOne: false
            referencedRelation: "eval_run"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "promotion_gate_result_tenant_id_gate_version_id_fkey"
            columns: ["tenant_id", "gate_version_id"]
            isOneToOne: false
            referencedRelation: "promotion_gate_version"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      promotion_gate_version: {
        Row: {
          created_at: string
          definition: Json
          definition_sha256: string
          id: string
          slug: string
          tenant_id: string
          version: number
        }
        Insert: {
          created_at?: string
          definition: Json
          definition_sha256: string
          id?: string
          slug: string
          tenant_id?: string
          version: number
        }
        Update: {
          created_at?: string
          definition?: Json
          definition_sha256?: string
          id?: string
          slug?: string
          tenant_id?: string
          version?: number
        }
        Relationships: []
      }
      regression: {
        Row: {
          baseline_run_id: string
          baseline_value: number | null
          current_run_id: string
          current_value: number | null
          delta: number | null
          detected_at: string
          gate_id: string | null
          id: string
          metric: string
        }
        Insert: {
          baseline_run_id: string
          baseline_value?: number | null
          current_run_id: string
          current_value?: number | null
          delta?: number | null
          detected_at?: string
          gate_id?: string | null
          id?: string
          metric: string
        }
        Update: {
          baseline_run_id?: string
          baseline_value?: number | null
          current_run_id?: string
          current_value?: number | null
          delta?: number | null
          detected_at?: string
          gate_id?: string | null
          id?: string
          metric?: string
        }
        Relationships: [
          {
            foreignKeyName: "regression_baseline_run_id_fkey"
            columns: ["baseline_run_id"]
            isOneToOne: false
            referencedRelation: "eval_run"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "regression_current_run_id_fkey"
            columns: ["current_run_id"]
            isOneToOne: false
            referencedRelation: "eval_run"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "regression_gate_id_fkey"
            columns: ["gate_id"]
            isOneToOne: false
            referencedRelation: "gate"
            referencedColumns: ["id"]
          },
        ]
      }
      regression_baseline: {
        Row: {
          baseline_sha256: string
          created_at: string
          gate_result_id: string
          id: string
          name: string
          tenant_id: string
          vector_space_version_id: string | null
        }
        Insert: {
          baseline_sha256: string
          created_at?: string
          gate_result_id: string
          id?: string
          name: string
          tenant_id?: string
          vector_space_version_id?: string | null
        }
        Update: {
          baseline_sha256?: string
          created_at?: string
          gate_result_id?: string
          id?: string
          name?: string
          tenant_id?: string
          vector_space_version_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "regression_baseline_tenant_id_gate_result_id_fkey"
            columns: ["tenant_id", "gate_result_id"]
            isOneToOne: false
            referencedRelation: "promotion_gate_result"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      review_decision: {
        Row: {
          decided_at: string
          decided_by: string
          decision: string
          eval_label_id: string | null
          id: string
          rationale: string
          review_task_id: string
        }
        Insert: {
          decided_at?: string
          decided_by: string
          decision: string
          eval_label_id?: string | null
          id?: string
          rationale: string
          review_task_id: string
        }
        Update: {
          decided_at?: string
          decided_by?: string
          decision?: string
          eval_label_id?: string | null
          id?: string
          rationale?: string
          review_task_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "review_decision_eval_label_id_fkey"
            columns: ["eval_label_id"]
            isOneToOne: false
            referencedRelation: "eval_label"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "review_decision_review_task_id_fkey"
            columns: ["review_task_id"]
            isOneToOne: false
            referencedRelation: "review_task"
            referencedColumns: ["id"]
          },
        ]
      }
      review_task: {
        Row: {
          assignee: string | null
          candidate_id: string | null
          capability_version_id: string | null
          claim_conflict_id: string | null
          claim_id: string | null
          created_at: string
          detail: Json
          entity_merge_id: string | null
          id: string
          operation_intent_id: string | null
          priority: number
          quorum_required: number
          state: Database["evaluation"]["Enums"]["review_state"]
          subject_kind: string | null
          summary: string
          task_kind: string
          tenant_id: string
          updated_at: string
          vector_space_version_id: string | null
        }
        Insert: {
          assignee?: string | null
          candidate_id?: string | null
          capability_version_id?: string | null
          claim_conflict_id?: string | null
          claim_id?: string | null
          created_at?: string
          detail?: Json
          entity_merge_id?: string | null
          id?: string
          operation_intent_id?: string | null
          priority?: number
          quorum_required?: number
          state?: Database["evaluation"]["Enums"]["review_state"]
          subject_kind?: string | null
          summary: string
          task_kind: string
          tenant_id?: string
          updated_at?: string
          vector_space_version_id?: string | null
        }
        Update: {
          assignee?: string | null
          candidate_id?: string | null
          capability_version_id?: string | null
          claim_conflict_id?: string | null
          claim_id?: string | null
          created_at?: string
          detail?: Json
          entity_merge_id?: string | null
          id?: string
          operation_intent_id?: string | null
          priority?: number
          quorum_required?: number
          state?: Database["evaluation"]["Enums"]["review_state"]
          subject_kind?: string | null
          summary?: string
          task_kind?: string
          tenant_id?: string
          updated_at?: string
          vector_space_version_id?: string | null
        }
        Relationships: []
      }
      verification_benchmark_arm_publication: {
        Row: {
          benchmark_arm_id: string
          benchmark_run_id: string
          configuration_artifact_id: string
          configuration_sha256: string
          created_at: string
          eval_run_id: string
          experiment_arm_id: string
          id: string
          operation_id: string
          policy_artifact_id: string
          policy_sha256: string
          publication_manifest_artifact_id: string
          publication_manifest_sha256: string
          target_code_ref: string
          tenant_id: string
          terminal_status: string
        }
        Insert: {
          benchmark_arm_id: string
          benchmark_run_id: string
          configuration_artifact_id: string
          configuration_sha256: string
          created_at?: string
          eval_run_id: string
          experiment_arm_id: string
          id?: string
          operation_id: string
          policy_artifact_id: string
          policy_sha256: string
          publication_manifest_artifact_id: string
          publication_manifest_sha256: string
          target_code_ref: string
          tenant_id?: string
          terminal_status: string
        }
        Update: {
          benchmark_arm_id?: string
          benchmark_run_id?: string
          configuration_artifact_id?: string
          configuration_sha256?: string
          created_at?: string
          eval_run_id?: string
          experiment_arm_id?: string
          id?: string
          operation_id?: string
          policy_artifact_id?: string
          policy_sha256?: string
          publication_manifest_artifact_id?: string
          publication_manifest_sha256?: string
          target_code_ref?: string
          tenant_id?: string
          terminal_status?: string
        }
        Relationships: [
          {
            foreignKeyName: "verification_benchmark_arm_pub_tenant_id_experiment_arm_id_fkey"
            columns: ["tenant_id", "experiment_arm_id"]
            isOneToOne: false
            referencedRelation: "experiment_arm"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "verification_benchmark_arm_publ_tenant_id_benchmark_run_id_fkey"
            columns: ["tenant_id", "benchmark_run_id"]
            isOneToOne: false
            referencedRelation: "verification_benchmark_run"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "verification_benchmark_arm_publicati_tenant_id_eval_run_id_fkey"
            columns: ["tenant_id", "eval_run_id"]
            isOneToOne: true
            referencedRelation: "eval_run"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      verification_benchmark_checkpoint: {
        Row: {
          benchmark_run_id: string
          checkpoint_context_sha256: string
          checkpoint_sha256: string
          completed_at: string
          created_at: string
          id: string
          result: Json
          result_sha256: string
          tenant_id: string
        }
        Insert: {
          benchmark_run_id: string
          checkpoint_context_sha256: string
          checkpoint_sha256: string
          completed_at: string
          created_at?: string
          id?: string
          result: Json
          result_sha256: string
          tenant_id?: string
        }
        Update: {
          benchmark_run_id?: string
          checkpoint_context_sha256?: string
          checkpoint_sha256?: string
          completed_at?: string
          created_at?: string
          id?: string
          result?: Json
          result_sha256?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "verification_benchmark_checkpoi_tenant_id_benchmark_run_id_fkey"
            columns: ["tenant_id", "benchmark_run_id"]
            isOneToOne: false
            referencedRelation: "verification_benchmark_run"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      verification_benchmark_comparison: {
        Row: {
          baseline_payload_sha256: string
          baseline_publication_artifact_id: string
          baseline_publication_sha256: string
          baseline_run_id: string
          candidate_payload_sha256: string
          candidate_publication_artifact_id: string
          candidate_publication_sha256: string
          candidate_run_id: string
          completed_at: string | null
          engineering_gate_outcome: string | null
          id: string
          operation_id: string
          profile_artifact_id: string
          profile_id: string
          profile_sha256: string
          publication_artifact_id: string | null
          publication_payload_sha256: string | null
          publication_sha256: string | null
          result_artifact_id: string | null
          result_digest_sha256: string | null
          result_sha256: string | null
          runtime: Json
          runtime_sha256: string
          started_at: string
          status: string
          tenant_id: string
        }
        Insert: {
          baseline_payload_sha256: string
          baseline_publication_artifact_id: string
          baseline_publication_sha256: string
          baseline_run_id: string
          candidate_payload_sha256: string
          candidate_publication_artifact_id: string
          candidate_publication_sha256: string
          candidate_run_id: string
          completed_at?: string | null
          engineering_gate_outcome?: string | null
          id?: string
          operation_id: string
          profile_artifact_id: string
          profile_id: string
          profile_sha256: string
          publication_artifact_id?: string | null
          publication_payload_sha256?: string | null
          publication_sha256?: string | null
          result_artifact_id?: string | null
          result_digest_sha256?: string | null
          result_sha256?: string | null
          runtime: Json
          runtime_sha256: string
          started_at?: string
          status?: string
          tenant_id?: string
        }
        Update: {
          baseline_payload_sha256?: string
          baseline_publication_artifact_id?: string
          baseline_publication_sha256?: string
          baseline_run_id?: string
          candidate_payload_sha256?: string
          candidate_publication_artifact_id?: string
          candidate_publication_sha256?: string
          candidate_run_id?: string
          completed_at?: string | null
          engineering_gate_outcome?: string | null
          id?: string
          operation_id?: string
          profile_artifact_id?: string
          profile_id?: string
          profile_sha256?: string
          publication_artifact_id?: string | null
          publication_payload_sha256?: string | null
          publication_sha256?: string | null
          result_artifact_id?: string | null
          result_digest_sha256?: string | null
          result_sha256?: string | null
          runtime?: Json
          runtime_sha256?: string
          started_at?: string
          status?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "verification_benchmark_comparis_tenant_id_candidate_run_id_fkey"
            columns: ["tenant_id", "candidate_run_id"]
            isOneToOne: false
            referencedRelation: "verification_benchmark_run"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "verification_benchmark_compariso_tenant_id_baseline_run_id_fkey"
            columns: ["tenant_id", "baseline_run_id"]
            isOneToOne: false
            referencedRelation: "verification_benchmark_run"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      verification_benchmark_run: {
        Row: {
          checkpoint_plan: Json
          checkpoint_plan_sha256: string
          completed_at: string | null
          created_at: string
          dataset_artifact_id: string
          dataset_sha256: string
          expected_checkpoint_count: number
          experiment_artifact_id: string
          experiment_sha256: string
          id: string
          network_policy: string
          operation_id: string
          random_seed: number
          repetitions: number
          run_manifest_artifact_id: string | null
          run_manifest_sha256: string | null
          runner_version: string
          started_at: string
          status: string
          tenant_id: string
        }
        Insert: {
          checkpoint_plan: Json
          checkpoint_plan_sha256: string
          completed_at?: string | null
          created_at?: string
          dataset_artifact_id: string
          dataset_sha256: string
          expected_checkpoint_count: number
          experiment_artifact_id: string
          experiment_sha256: string
          id: string
          network_policy: string
          operation_id: string
          random_seed: number
          repetitions: number
          run_manifest_artifact_id?: string | null
          run_manifest_sha256?: string | null
          runner_version: string
          started_at: string
          status: string
          tenant_id?: string
        }
        Update: {
          checkpoint_plan?: Json
          checkpoint_plan_sha256?: string
          completed_at?: string | null
          created_at?: string
          dataset_artifact_id?: string
          dataset_sha256?: string
          expected_checkpoint_count?: number
          experiment_artifact_id?: string
          experiment_sha256?: string
          id?: string
          network_policy?: string
          operation_id?: string
          random_seed?: number
          repetitions?: number
          run_manifest_artifact_id?: string | null
          run_manifest_sha256?: string | null
          runner_version?: string
          started_at?: string
          status?: string
          tenant_id?: string
        }
        Relationships: []
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      verification_case_artifacts_are_admitted: {
        Args: {
          p_dataset_id: string
          p_dataset_version_id: string
          p_gold_artifact_id: string
          p_input_artifact_id: string
          p_tenant_id: string
        }
        Returns: boolean
      }
    }
    Enums: {
      gate_action:
        | "block"
        | "quarantine"
        | "repair"
        | "rerun"
        | "review"
        | "escalate"
        | "optimize"
        | "allow"
      review_state:
        | "open"
        | "claimed"
        | "in_review"
        | "decided"
        | "escalated"
        | "cancelled"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  evidence: {
    Tables: {
      attribution: {
        Row: {
          claim_id: string | null
          entity_id: string
          extraction_record_id: string | null
          id: string
          locator_id: string | null
          role: string
          source_id: string | null
          tenant_id: string
        }
        Insert: {
          claim_id?: string | null
          entity_id: string
          extraction_record_id?: string | null
          id?: string
          locator_id?: string | null
          role: string
          source_id?: string | null
          tenant_id?: string
        }
        Update: {
          claim_id?: string | null
          entity_id?: string
          extraction_record_id?: string | null
          id?: string
          locator_id?: string | null
          role?: string
          source_id?: string | null
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "attribution_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "claim"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "attribution_extraction_record_id_fkey"
            columns: ["extraction_record_id"]
            isOneToOne: false
            referencedRelation: "extraction_record"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "attribution_locator_id_fkey"
            columns: ["locator_id"]
            isOneToOne: false
            referencedRelation: "locator"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "attribution_source_id_fkey"
            columns: ["source_id"]
            isOneToOne: false
            referencedRelation: "source"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "attribution_tenant_id_claim_id_fkey"
            columns: ["tenant_id", "claim_id"]
            isOneToOne: false
            referencedRelation: "claim"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "attribution_tenant_id_extraction_record_id_fkey"
            columns: ["tenant_id", "extraction_record_id"]
            isOneToOne: false
            referencedRelation: "extraction_record"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "attribution_tenant_id_locator_id_fkey"
            columns: ["tenant_id", "locator_id"]
            isOneToOne: false
            referencedRelation: "locator"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "attribution_tenant_id_source_id_fkey"
            columns: ["tenant_id", "source_id"]
            isOneToOne: false
            referencedRelation: "source"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      capture_method: {
        Row: {
          code: string
          description: string
        }
        Insert: {
          code: string
          description: string
        }
        Update: {
          code?: string
          description?: string
        }
        Relationships: []
      }
      claim: {
        Row: {
          atomized_from_id: string | null
          claim_type: string
          composite: boolean
          created_at: string
          created_by_receipt_id: string | null
          id: string
          producer_attempt_id: string | null
          producer_origin_digest: string | null
          relationship_id: string | null
          statement: string
          status: Database["evidence"]["Enums"]["claim_status"]
          structured: Json | null
          superseded_by_id: string | null
          tenant_id: string
          updated_at: string
        }
        Insert: {
          atomized_from_id?: string | null
          claim_type: string
          composite?: boolean
          created_at?: string
          created_by_receipt_id?: string | null
          id?: string
          producer_attempt_id?: string | null
          producer_origin_digest?: string | null
          relationship_id?: string | null
          statement: string
          status?: Database["evidence"]["Enums"]["claim_status"]
          structured?: Json | null
          superseded_by_id?: string | null
          tenant_id?: string
          updated_at?: string
        }
        Update: {
          atomized_from_id?: string | null
          claim_type?: string
          composite?: boolean
          created_at?: string
          created_by_receipt_id?: string | null
          id?: string
          producer_attempt_id?: string | null
          producer_origin_digest?: string | null
          relationship_id?: string | null
          statement?: string
          status?: Database["evidence"]["Enums"]["claim_status"]
          structured?: Json | null
          superseded_by_id?: string | null
          tenant_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "claim_atomized_from_id_fkey"
            columns: ["atomized_from_id"]
            isOneToOne: false
            referencedRelation: "claim"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "claim_claim_type_fkey"
            columns: ["claim_type"]
            isOneToOne: false
            referencedRelation: "claim_type"
            referencedColumns: ["code"]
          },
          {
            foreignKeyName: "claim_superseded_by_id_fkey"
            columns: ["superseded_by_id"]
            isOneToOne: false
            referencedRelation: "claim"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "claim_tenant_atomized_from_fk"
            columns: ["tenant_id", "atomized_from_id"]
            isOneToOne: false
            referencedRelation: "claim"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "claim_tenant_superseded_by_fk"
            columns: ["tenant_id", "superseded_by_id"]
            isOneToOne: false
            referencedRelation: "claim"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      claim_conflict: {
        Row: {
          claim_a_id: string
          claim_b_id: string
          conflict_kind: string
          detected_at: string
          detected_by: string
          id: string
        }
        Insert: {
          claim_a_id: string
          claim_b_id: string
          conflict_kind: string
          detected_at?: string
          detected_by: string
          id?: string
        }
        Update: {
          claim_a_id?: string
          claim_b_id?: string
          conflict_kind?: string
          detected_at?: string
          detected_by?: string
          id?: string
        }
        Relationships: [
          {
            foreignKeyName: "claim_conflict_claim_a_id_fkey"
            columns: ["claim_a_id"]
            isOneToOne: false
            referencedRelation: "claim"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "claim_conflict_claim_b_id_fkey"
            columns: ["claim_b_id"]
            isOneToOne: false
            referencedRelation: "claim"
            referencedColumns: ["id"]
          },
        ]
      }
      claim_evidence_link: {
        Row: {
          authority_assessment: Json | null
          claim_id: string
          created_at: string
          id: string
          locator_id: string
          role: string
          support_verdict:
            | Database["evidence"]["Enums"]["support_verdict"]
            | null
          tenant_id: string | null
          verification_contract_version: string | null
        }
        Insert: {
          authority_assessment?: Json | null
          claim_id: string
          created_at?: string
          id?: string
          locator_id: string
          role: string
          support_verdict?:
            | Database["evidence"]["Enums"]["support_verdict"]
            | null
          tenant_id?: string | null
          verification_contract_version?: string | null
        }
        Update: {
          authority_assessment?: Json | null
          claim_id?: string
          created_at?: string
          id?: string
          locator_id?: string
          role?: string
          support_verdict?:
            | Database["evidence"]["Enums"]["support_verdict"]
            | null
          tenant_id?: string | null
          verification_contract_version?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "claim_evidence_link_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "claim"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "claim_evidence_link_locator_id_fkey"
            columns: ["locator_id"]
            isOneToOne: false
            referencedRelation: "locator"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "claim_evidence_link_tenant_claim_fk"
            columns: ["tenant_id", "claim_id"]
            isOneToOne: false
            referencedRelation: "claim"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "claim_evidence_link_tenant_locator_fk"
            columns: ["tenant_id", "locator_id"]
            isOneToOne: false
            referencedRelation: "locator"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      claim_record: {
        Row: {
          claim_id: string
          record_id: string
          tenant_id: string
        }
        Insert: {
          claim_id: string
          record_id: string
          tenant_id?: string
        }
        Update: {
          claim_id?: string
          record_id?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "claim_record_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "claim"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "claim_record_tenant_id_claim_id_fkey"
            columns: ["tenant_id", "claim_id"]
            isOneToOne: false
            referencedRelation: "claim"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      claim_subject: {
        Row: {
          claim_id: string
          entity_id: string
          role: string
          tenant_id: string
        }
        Insert: {
          claim_id: string
          entity_id: string
          role: string
          tenant_id?: string
        }
        Update: {
          claim_id?: string
          entity_id?: string
          role?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "claim_subject_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "claim"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "claim_subject_tenant_id_claim_id_fkey"
            columns: ["tenant_id", "claim_id"]
            isOneToOne: false
            referencedRelation: "claim"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      claim_type: {
        Row: {
          code: string
          created_at: string
          description: string
        }
        Insert: {
          code: string
          created_at?: string
          description: string
        }
        Update: {
          code?: string
          created_at?: string
          description?: string
        }
        Relationships: []
      }
      conflict_reconciliation: {
        Row: {
          conflict_id: string
          decided_at: string
          id: string
          outcome: string
          rationale: string
          review_task_id: string | null
        }
        Insert: {
          conflict_id: string
          decided_at?: string
          id?: string
          outcome: string
          rationale: string
          review_task_id?: string | null
        }
        Update: {
          conflict_id?: string
          decided_at?: string
          id?: string
          outcome?: string
          rationale?: string
          review_task_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "conflict_reconciliation_conflict_id_fkey"
            columns: ["conflict_id"]
            isOneToOne: false
            referencedRelation: "claim_conflict"
            referencedColumns: ["id"]
          },
        ]
      }
      degraded_assurance: {
        Row: {
          approved_at: string | null
          approved_by_review_task_id: string | null
          attempted_methods: Json
          created_at: string
          id: string
          reason: string
          source_id: string
          what_was_seen: string
        }
        Insert: {
          approved_at?: string | null
          approved_by_review_task_id?: string | null
          attempted_methods?: Json
          created_at?: string
          id?: string
          reason: string
          source_id: string
          what_was_seen: string
        }
        Update: {
          approved_at?: string | null
          approved_by_review_task_id?: string | null
          attempted_methods?: Json
          created_at?: string
          id?: string
          reason?: string
          source_id?: string
          what_was_seen?: string
        }
        Relationships: [
          {
            foreignKeyName: "degraded_assurance_source_id_fkey"
            columns: ["source_id"]
            isOneToOne: false
            referencedRelation: "source"
            referencedColumns: ["id"]
          },
        ]
      }
      extraction_record: {
        Row: {
          claim_id: string | null
          confidence: number | null
          created_at: string
          document_node_id: string | null
          extraction_run_id: string
          id: string
          locator_id: string | null
          mapping_id: string | null
          payload: Json
          record_kind: string
          tenant_id: string
        }
        Insert: {
          claim_id?: string | null
          confidence?: number | null
          created_at?: string
          document_node_id?: string | null
          extraction_run_id: string
          id?: string
          locator_id?: string | null
          mapping_id?: string | null
          payload: Json
          record_kind: string
          tenant_id?: string
        }
        Update: {
          claim_id?: string | null
          confidence?: number | null
          created_at?: string
          document_node_id?: string | null
          extraction_run_id?: string
          id?: string
          locator_id?: string | null
          mapping_id?: string | null
          payload?: Json
          record_kind?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "extraction_record_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "claim"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "extraction_record_extraction_run_id_fkey"
            columns: ["extraction_run_id"]
            isOneToOne: false
            referencedRelation: "extraction_run"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "extraction_record_locator_id_fkey"
            columns: ["locator_id"]
            isOneToOne: false
            referencedRelation: "locator"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "extraction_record_tenant_id_claim_id_fkey"
            columns: ["tenant_id", "claim_id"]
            isOneToOne: false
            referencedRelation: "claim"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "extraction_record_tenant_id_extraction_run_id_fkey"
            columns: ["tenant_id", "extraction_run_id"]
            isOneToOne: false
            referencedRelation: "extraction_run"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "extraction_record_tenant_id_locator_id_fkey"
            columns: ["tenant_id", "locator_id"]
            isOneToOne: false
            referencedRelation: "locator"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      extraction_run: {
        Row: {
          attempt_id: string | null
          created_at: string
          extractor_identity: string
          extractor_version: string
          id: string
          input_digest: string
          parameters: Json
          representation_id: string | null
          result_artifact_id: string | null
          tenant_id: string
        }
        Insert: {
          attempt_id?: string | null
          created_at?: string
          extractor_identity: string
          extractor_version: string
          id?: string
          input_digest: string
          parameters?: Json
          representation_id?: string | null
          result_artifact_id?: string | null
          tenant_id?: string
        }
        Update: {
          attempt_id?: string | null
          created_at?: string
          extractor_identity?: string
          extractor_version?: string
          id?: string
          input_digest?: string
          parameters?: Json
          representation_id?: string | null
          result_artifact_id?: string | null
          tenant_id?: string
        }
        Relationships: []
      }
      extraction_signature: {
        Row: {
          created_at: string
          id: string
          locator_id: string
          produced_by_attempt_id: string
          signature_sha256: string
          tenant_id: string | null
          verification_contract_version: string | null
        }
        Insert: {
          created_at?: string
          id?: string
          locator_id: string
          produced_by_attempt_id: string
          signature_sha256: string
          tenant_id?: string | null
          verification_contract_version?: string | null
        }
        Update: {
          created_at?: string
          id?: string
          locator_id?: string
          produced_by_attempt_id?: string
          signature_sha256?: string
          tenant_id?: string | null
          verification_contract_version?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "extraction_signature_locator_id_fkey"
            columns: ["locator_id"]
            isOneToOne: false
            referencedRelation: "locator"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "extraction_signature_tenant_locator_fk"
            columns: ["tenant_id", "locator_id"]
            isOneToOne: false
            referencedRelation: "locator"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      locator: {
        Row: {
          capture_id: string
          context_fingerprint: string | null
          created_at: string
          end_ms: number | null
          extraction_params: Json
          extractor_name: string
          extractor_version: string
          id: string
          media_type: string
          normalization_policy: string | null
          normalized_value: string | null
          occurrence_count: number | null
          page_number: number | null
          representation_artifact_id: string | null
          resolution_state: string | null
          resolution_version: string | null
          selected_content_sha256: string | null
          selected_size_bytes: number | null
          selector: Json
          selector_kind: string
          selector_sha256: string | null
          start_ms: number | null
          tenant_id: string | null
          verification_contract_version: string | null
        }
        Insert: {
          capture_id: string
          context_fingerprint?: string | null
          created_at?: string
          end_ms?: number | null
          extraction_params?: Json
          extractor_name: string
          extractor_version: string
          id?: string
          media_type: string
          normalization_policy?: string | null
          normalized_value?: string | null
          occurrence_count?: number | null
          page_number?: number | null
          representation_artifact_id?: string | null
          resolution_state?: string | null
          resolution_version?: string | null
          selected_content_sha256?: string | null
          selected_size_bytes?: number | null
          selector: Json
          selector_kind?: string
          selector_sha256?: string | null
          start_ms?: number | null
          tenant_id?: string | null
          verification_contract_version?: string | null
        }
        Update: {
          capture_id?: string
          context_fingerprint?: string | null
          created_at?: string
          end_ms?: number | null
          extraction_params?: Json
          extractor_name?: string
          extractor_version?: string
          id?: string
          media_type?: string
          normalization_policy?: string | null
          normalized_value?: string | null
          occurrence_count?: number | null
          page_number?: number | null
          representation_artifact_id?: string | null
          resolution_state?: string | null
          resolution_version?: string | null
          selected_content_sha256?: string | null
          selected_size_bytes?: number | null
          selector?: Json
          selector_kind?: string
          selector_sha256?: string | null
          start_ms?: number | null
          tenant_id?: string | null
          verification_contract_version?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "locator_capture_id_fkey"
            columns: ["capture_id"]
            isOneToOne: false
            referencedRelation: "source_capture"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "locator_tenant_capture_fk"
            columns: ["tenant_id", "capture_id"]
            isOneToOne: false
            referencedRelation: "source_capture"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      provider_result: {
        Row: {
          artifact_id: string | null
          created_at: string
          disposition: string | null
          id: string
          payload: Json
          provider_native_result_id: string | null
          query_id: string
          rank: number
          snippet: string | null
          source_id: string | null
          source_provider_attempt_id: string | null
          tenant_id: string
          title: string | null
          url: string | null
        }
        Insert: {
          artifact_id?: string | null
          created_at?: string
          disposition?: string | null
          id?: string
          payload?: Json
          provider_native_result_id?: string | null
          query_id: string
          rank: number
          snippet?: string | null
          source_id?: string | null
          source_provider_attempt_id?: string | null
          tenant_id?: string
          title?: string | null
          url?: string | null
        }
        Update: {
          artifact_id?: string | null
          created_at?: string
          disposition?: string | null
          id?: string
          payload?: Json
          provider_native_result_id?: string | null
          query_id?: string
          rank?: number
          snippet?: string | null
          source_id?: string | null
          source_provider_attempt_id?: string | null
          tenant_id?: string
          title?: string | null
          url?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "provider_result_query_id_fkey"
            columns: ["query_id"]
            isOneToOne: false
            referencedRelation: "source_query"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "provider_result_source_id_fkey"
            columns: ["source_id"]
            isOneToOne: false
            referencedRelation: "source"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "provider_result_source_provider_attempt_id_fkey"
            columns: ["source_provider_attempt_id"]
            isOneToOne: false
            referencedRelation: "source_provider_attempt"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "provider_result_tenant_attempt_fk"
            columns: ["tenant_id", "source_provider_attempt_id"]
            isOneToOne: false
            referencedRelation: "source_provider_attempt"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "provider_result_tenant_id_query_id_fkey"
            columns: ["tenant_id", "query_id"]
            isOneToOne: false
            referencedRelation: "source_query"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "provider_result_tenant_id_source_id_fkey"
            columns: ["tenant_id", "source_id"]
            isOneToOne: false
            referencedRelation: "source"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      revalidation_event: {
        Row: {
          affected_refs: Json
          fired_at: string
          id: string
          policy_id: string | null
          trigger_kind: string
          work_item_id: string | null
        }
        Insert: {
          affected_refs?: Json
          fired_at?: string
          id?: string
          policy_id?: string | null
          trigger_kind: string
          work_item_id?: string | null
        }
        Update: {
          affected_refs?: Json
          fired_at?: string
          id?: string
          policy_id?: string | null
          trigger_kind?: string
          work_item_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "revalidation_event_policy_id_fkey"
            columns: ["policy_id"]
            isOneToOne: false
            referencedRelation: "revalidation_policy"
            referencedColumns: ["id"]
          },
        ]
      }
      revalidation_policy: {
        Row: {
          applies_to: string
          created_at: string
          id: string
          max_age: string | null
          rules: Json
          slug: string
        }
        Insert: {
          applies_to: string
          created_at?: string
          id?: string
          max_age?: string | null
          rules?: Json
          slug: string
        }
        Update: {
          applies_to?: string
          created_at?: string
          id?: string
          max_age?: string | null
          rules?: Json
          slug?: string
        }
        Relationships: []
      }
      search_provider: {
        Row: {
          code: string
          description: string
          provider_kind: string
        }
        Insert: {
          code: string
          description: string
          provider_kind?: string
        }
        Update: {
          code?: string
          description?: string
          provider_kind?: string
        }
        Relationships: []
      }
      segment_support: {
        Row: {
          claim_id: string
          event_occurrence_id: string | null
          id: string
          k_from: number
          k_to: number | null
          locator_id: string
          role: string
          segment_id: string | null
          tenant_id: string
        }
        Insert: {
          claim_id: string
          event_occurrence_id?: string | null
          id?: string
          k_from: number
          k_to?: number | null
          locator_id: string
          role: string
          segment_id?: string | null
          tenant_id?: string
        }
        Update: {
          claim_id?: string
          event_occurrence_id?: string | null
          id?: string
          k_from?: number
          k_to?: number | null
          locator_id?: string
          role?: string
          segment_id?: string | null
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "segment_support_claim_id_fkey"
            columns: ["claim_id"]
            isOneToOne: false
            referencedRelation: "claim"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "segment_support_locator_id_fkey"
            columns: ["locator_id"]
            isOneToOne: false
            referencedRelation: "locator"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "segment_support_tenant_id_claim_id_fkey"
            columns: ["tenant_id", "claim_id"]
            isOneToOne: false
            referencedRelation: "claim"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "segment_support_tenant_id_locator_id_fkey"
            columns: ["tenant_id", "locator_id"]
            isOneToOne: false
            referencedRelation: "locator"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      source: {
        Row: {
          blocked_reason: string | null
          canonical_url: string | null
          capture_count: number
          channel_entity_id: string | null
          created_at: string
          failure_streak: number
          first_seen_at: string | null
          host: string | null
          id: string
          last_capture_id: string | null
          last_encounter_kind: string | null
          last_seen_at: string | null
          license_notes: string | null
          license_spdx: string | null
          logical_identity: string | null
          next_revisit_after: string | null
          publisher: string | null
          publisher_entity_id: string | null
          registrable_domain: string | null
          robots_policy: string | null
          sensitivity: string
          source_class: string
          source_kind: string | null
          state_knowledge_seq: number | null
          tenant_id: string
          terms_url: string | null
          updated_at: string
          url_pattern: string | null
          verification_contract_version: string | null
        }
        Insert: {
          blocked_reason?: string | null
          canonical_url?: string | null
          capture_count?: number
          channel_entity_id?: string | null
          created_at?: string
          failure_streak?: number
          first_seen_at?: string | null
          host?: string | null
          id?: string
          last_capture_id?: string | null
          last_encounter_kind?: string | null
          last_seen_at?: string | null
          license_notes?: string | null
          license_spdx?: string | null
          logical_identity?: string | null
          next_revisit_after?: string | null
          publisher?: string | null
          publisher_entity_id?: string | null
          registrable_domain?: string | null
          robots_policy?: string | null
          sensitivity?: string
          source_class: string
          source_kind?: string | null
          state_knowledge_seq?: number | null
          tenant_id?: string
          terms_url?: string | null
          updated_at?: string
          url_pattern?: string | null
          verification_contract_version?: string | null
        }
        Update: {
          blocked_reason?: string | null
          canonical_url?: string | null
          capture_count?: number
          channel_entity_id?: string | null
          created_at?: string
          failure_streak?: number
          first_seen_at?: string | null
          host?: string | null
          id?: string
          last_capture_id?: string | null
          last_encounter_kind?: string | null
          last_seen_at?: string | null
          license_notes?: string | null
          license_spdx?: string | null
          logical_identity?: string | null
          next_revisit_after?: string | null
          publisher?: string | null
          publisher_entity_id?: string | null
          registrable_domain?: string | null
          robots_policy?: string | null
          sensitivity?: string
          source_class?: string
          source_kind?: string | null
          state_knowledge_seq?: number | null
          tenant_id?: string
          terms_url?: string | null
          updated_at?: string
          url_pattern?: string | null
          verification_contract_version?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "source_last_capture_id_fkey"
            columns: ["last_capture_id"]
            isOneToOne: false
            referencedRelation: "source_capture"
            referencedColumns: ["id"]
          },
        ]
      }
      source_assessment: {
        Row: {
          as_of: string
          assessed_by: string
          authority_score: number | null
          claims_checked: number
          claims_observed: number
          confirmed: number
          conflict_of_interest: string
          created_at: string
          id: string
          inputs: Json
          median_lead_days: number | null
          method: string
          method_disclosure: string
          noise_ratio: number | null
          qualified: number
          rationale: string
          receipt_id: string | null
          recommended_watch_level: string | null
          refuted: number
          self_checked: number
          source_role_code: string | null
          subject_entity_id: string
          supersedes_id: string | null
          tenant_id: string
          topic_entity_id: string | null
        }
        Insert: {
          as_of?: string
          assessed_by: string
          authority_score?: number | null
          claims_checked?: number
          claims_observed?: number
          confirmed?: number
          conflict_of_interest?: string
          created_at?: string
          id?: string
          inputs?: Json
          median_lead_days?: number | null
          method: string
          method_disclosure?: string
          noise_ratio?: number | null
          qualified?: number
          rationale: string
          receipt_id?: string | null
          recommended_watch_level?: string | null
          refuted?: number
          self_checked?: number
          source_role_code?: string | null
          subject_entity_id: string
          supersedes_id?: string | null
          tenant_id?: string
          topic_entity_id?: string | null
        }
        Update: {
          as_of?: string
          assessed_by?: string
          authority_score?: number | null
          claims_checked?: number
          claims_observed?: number
          confirmed?: number
          conflict_of_interest?: string
          created_at?: string
          id?: string
          inputs?: Json
          median_lead_days?: number | null
          method?: string
          method_disclosure?: string
          noise_ratio?: number | null
          qualified?: number
          rationale?: string
          receipt_id?: string | null
          recommended_watch_level?: string | null
          refuted?: number
          self_checked?: number
          source_role_code?: string | null
          subject_entity_id?: string
          supersedes_id?: string | null
          tenant_id?: string
          topic_entity_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "source_assessment_supersedes_id_fkey"
            columns: ["supersedes_id"]
            isOneToOne: false
            referencedRelation: "source_assessment"
            referencedColumns: ["id"]
          },
        ]
      }
      source_capture: {
        Row: {
          acquisition_fetch_id: string | null
          artifact_id: string
          capture_method: string
          capture_method_version: string
          captured_at: string
          content_sha256: string
          context: Json
          http_headers: Json | null
          http_status: number | null
          id: string
          knowledge_operation_id: string | null
          media_type: string
          produced_by_attempt_id: string | null
          request_url: string | null
          source_id: string
          tenant_id: string
        }
        Insert: {
          acquisition_fetch_id?: string | null
          artifact_id: string
          capture_method: string
          capture_method_version: string
          captured_at?: string
          content_sha256: string
          context?: Json
          http_headers?: Json | null
          http_status?: number | null
          id?: string
          knowledge_operation_id?: string | null
          media_type: string
          produced_by_attempt_id?: string | null
          request_url?: string | null
          source_id: string
          tenant_id?: string
        }
        Update: {
          acquisition_fetch_id?: string | null
          artifact_id?: string
          capture_method?: string
          capture_method_version?: string
          captured_at?: string
          content_sha256?: string
          context?: Json
          http_headers?: Json | null
          http_status?: number | null
          id?: string
          knowledge_operation_id?: string | null
          media_type?: string
          produced_by_attempt_id?: string | null
          request_url?: string | null
          source_id?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "source_capture_capture_method_fkey"
            columns: ["capture_method"]
            isOneToOne: false
            referencedRelation: "capture_method"
            referencedColumns: ["code"]
          },
          {
            foreignKeyName: "source_capture_source_id_fkey"
            columns: ["source_id"]
            isOneToOne: false
            referencedRelation: "source"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "source_capture_tenant_source_fk"
            columns: ["tenant_id", "source_id"]
            isOneToOne: false
            referencedRelation: "source"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      source_encounter: {
        Row: {
          capture_id: string | null
          details: Json
          encounter_kind: string
          encountered_at: string
          failure_code: string | null
          final_url: string | null
          id: string
          provider_result_id: string | null
          receipt_id: string | null
          redirect_urls: string[]
          requested_url: string | null
          result_disposition: string | null
          source_id: string
          source_provider_attempt_id: string | null
          tenant_id: string
        }
        Insert: {
          capture_id?: string | null
          details?: Json
          encounter_kind: string
          encountered_at?: string
          failure_code?: string | null
          final_url?: string | null
          id?: string
          provider_result_id?: string | null
          receipt_id?: string | null
          redirect_urls?: string[]
          requested_url?: string | null
          result_disposition?: string | null
          source_id: string
          source_provider_attempt_id?: string | null
          tenant_id?: string
        }
        Update: {
          capture_id?: string | null
          details?: Json
          encounter_kind?: string
          encountered_at?: string
          failure_code?: string | null
          final_url?: string | null
          id?: string
          provider_result_id?: string | null
          receipt_id?: string | null
          redirect_urls?: string[]
          requested_url?: string | null
          result_disposition?: string | null
          source_id?: string
          source_provider_attempt_id?: string | null
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "source_encounter_capture_id_fkey"
            columns: ["capture_id"]
            isOneToOne: false
            referencedRelation: "source_capture"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "source_encounter_provider_result_id_fkey"
            columns: ["provider_result_id"]
            isOneToOne: false
            referencedRelation: "provider_result"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "source_encounter_source_id_fkey"
            columns: ["source_id"]
            isOneToOne: false
            referencedRelation: "source"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "source_encounter_source_provider_attempt_id_fkey"
            columns: ["source_provider_attempt_id"]
            isOneToOne: false
            referencedRelation: "source_provider_attempt"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "source_encounter_tenant_attempt_fk"
            columns: ["tenant_id", "source_provider_attempt_id"]
            isOneToOne: false
            referencedRelation: "source_provider_attempt"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "source_encounter_tenant_capture_fk"
            columns: ["tenant_id", "capture_id"]
            isOneToOne: false
            referencedRelation: "source_capture"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "source_encounter_tenant_id_capture_id_fkey"
            columns: ["tenant_id", "capture_id"]
            isOneToOne: false
            referencedRelation: "source_capture"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "source_encounter_tenant_id_provider_result_id_fkey"
            columns: ["tenant_id", "provider_result_id"]
            isOneToOne: false
            referencedRelation: "provider_result"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "source_encounter_tenant_id_source_id_fkey"
            columns: ["tenant_id", "source_id"]
            isOneToOne: false
            referencedRelation: "source"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      source_provider_attempt: {
        Row: {
          attempt_ordinal: number
          completed_at: string | null
          completion_artifact_id: string | null
          completion_sha256: string | null
          dispatch_claimed_at: string | null
          dispatch_expires_at: string | null
          dispatch_fencing_token: number
          dispatch_owner: string | null
          dispatch_token: string | null
          external_receipt_artifact_id: string | null
          failure_code: string | null
          id: string
          idempotency_key: string
          origin: string
          original_dispatch_fencing_token: number | null
          original_dispatch_token: string | null
          provider_code: string
          provider_native_attempt_id: string | null
          provider_version: string
          raw_output_artifact_id: string | null
          request_artifact_id: string
          request_sha256: string
          requested_urls: Json
          retry_of_attempt_id: string | null
          root_attempt_id: string | null
          source_query_id: string
          started_at: string
          state: string
          tenant_id: string
        }
        Insert: {
          attempt_ordinal?: number
          completed_at?: string | null
          completion_artifact_id?: string | null
          completion_sha256?: string | null
          dispatch_claimed_at?: string | null
          dispatch_expires_at?: string | null
          dispatch_fencing_token?: number
          dispatch_owner?: string | null
          dispatch_token?: string | null
          external_receipt_artifact_id?: string | null
          failure_code?: string | null
          id?: string
          idempotency_key: string
          origin: string
          original_dispatch_fencing_token?: number | null
          original_dispatch_token?: string | null
          provider_code: string
          provider_native_attempt_id?: string | null
          provider_version?: string
          raw_output_artifact_id?: string | null
          request_artifact_id: string
          request_sha256: string
          requested_urls?: Json
          retry_of_attempt_id?: string | null
          root_attempt_id?: string | null
          source_query_id: string
          started_at?: string
          state: string
          tenant_id?: string
        }
        Update: {
          attempt_ordinal?: number
          completed_at?: string | null
          completion_artifact_id?: string | null
          completion_sha256?: string | null
          dispatch_claimed_at?: string | null
          dispatch_expires_at?: string | null
          dispatch_fencing_token?: number
          dispatch_owner?: string | null
          dispatch_token?: string | null
          external_receipt_artifact_id?: string | null
          failure_code?: string | null
          id?: string
          idempotency_key?: string
          origin?: string
          original_dispatch_fencing_token?: number | null
          original_dispatch_token?: string | null
          provider_code?: string
          provider_native_attempt_id?: string | null
          provider_version?: string
          raw_output_artifact_id?: string | null
          request_artifact_id?: string
          request_sha256?: string
          requested_urls?: Json
          retry_of_attempt_id?: string | null
          root_attempt_id?: string | null
          source_query_id?: string
          started_at?: string
          state?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "source_attempt_retry_tenant_fk"
            columns: ["tenant_id", "retry_of_attempt_id"]
            isOneToOne: false
            referencedRelation: "source_provider_attempt"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "source_attempt_root_tenant_fk"
            columns: ["tenant_id", "root_attempt_id"]
            isOneToOne: false
            referencedRelation: "source_provider_attempt"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "source_provider_attempt_provider_code_fkey"
            columns: ["provider_code"]
            isOneToOne: false
            referencedRelation: "search_provider"
            referencedColumns: ["code"]
          },
          {
            foreignKeyName: "source_provider_attempt_source_query_id_fkey"
            columns: ["source_query_id"]
            isOneToOne: false
            referencedRelation: "source_query"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "source_provider_attempt_tenant_query_fk"
            columns: ["tenant_id", "source_query_id"]
            isOneToOne: false
            referencedRelation: "source_query"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      source_query: {
        Row: {
          attempt_id: string | null
          id: string
          parameters: Json
          provider_code: string
          purpose: string
          queried_at: string
          query_text: string
          response_artifact_id: string | null
          tenant_id: string
        }
        Insert: {
          attempt_id?: string | null
          id?: string
          parameters?: Json
          provider_code: string
          purpose: string
          queried_at?: string
          query_text: string
          response_artifact_id?: string | null
          tenant_id?: string
        }
        Update: {
          attempt_id?: string | null
          id?: string
          parameters?: Json
          provider_code?: string
          purpose?: string
          queried_at?: string
          query_text?: string
          response_artifact_id?: string | null
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "source_query_provider_code_fkey"
            columns: ["provider_code"]
            isOneToOne: false
            referencedRelation: "search_provider"
            referencedColumns: ["code"]
          },
        ]
      }
      source_result_selection: {
        Row: {
          attempt_id: string
          created_at: string
          disposition: string
          idempotency_key: string
          rank: number
          reason: string
          revision: number
          selection_artifact_id: string
          tenant_id: string
        }
        Insert: {
          attempt_id: string
          created_at?: string
          disposition: string
          idempotency_key: string
          rank: number
          reason: string
          revision: number
          selection_artifact_id: string
          tenant_id: string
        }
        Update: {
          attempt_id?: string
          created_at?: string
          disposition?: string
          idempotency_key?: string
          rank?: number
          reason?: string
          revision?: number
          selection_artifact_id?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "source_result_selection_tenant_id_attempt_id_fkey"
            columns: ["tenant_id", "attempt_id"]
            isOneToOne: false
            referencedRelation: "source_provider_attempt"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "source_result_selection_tenant_id_attempt_id_revision_idem_fkey"
            columns: [
              "tenant_id",
              "attempt_id",
              "revision",
              "idempotency_key",
              "selection_artifact_id",
            ]
            isOneToOne: false
            referencedRelation: "source_selection_revision"
            referencedColumns: [
              "tenant_id",
              "attempt_id",
              "revision",
              "idempotency_key",
              "selection_artifact_id",
            ]
          },
        ]
      }
      source_selection_revision: {
        Row: {
          attempt_id: string
          created_at: string
          idempotency_key: string
          request_sha256: string
          revision: number
          selection_artifact_id: string
          tenant_id: string
        }
        Insert: {
          attempt_id: string
          created_at?: string
          idempotency_key: string
          request_sha256: string
          revision: number
          selection_artifact_id: string
          tenant_id: string
        }
        Update: {
          attempt_id?: string
          created_at?: string
          idempotency_key?: string
          request_sha256?: string
          revision?: number
          selection_artifact_id?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "source_selection_revision_tenant_id_attempt_id_fkey"
            columns: ["tenant_id", "attempt_id"]
            isOneToOne: false
            referencedRelation: "source_provider_attempt"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      claim_is_self_stated: { Args: { p_claim: string }; Returns: boolean }
      derive_source_assessment: {
        Args: {
          p_assessed_by?: string
          p_note?: string
          p_subject: string
          p_topic?: string
        }
        Returns: string
      }
      rebuild_source_state: { Args: never; Returns: number }
      verification_locator_artifacts_are_admitted: {
        Args: {
          p_capture_id: string
          p_representation_artifact_id: string
          p_tenant_id: string
        }
        Returns: boolean
      }
    }
    Enums: {
      claim_status:
        | "proposed"
        | "verified"
        | "disputed"
        | "retracted"
        | "superseded"
      support_verdict:
        | "directly_supported"
        | "supported_with_qualification"
        | "partially_supported"
        | "context_only"
        | "contradicted"
        | "not_supported"
        | "unverifiable"
        | "pending_semantic_review"
        | "mixed_or_conflicting"
        | "insufficient_evidence"
        | "source_unavailable"
        | "locator_error"
        | "parser_error"
        | "derived_verified"
        | "derived_failed"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  guidance: {
    Tables: {
      assurance_level: {
        Row: {
          code: string
          description: string
          rank: number
        }
        Insert: {
          code: string
          description: string
          rank: number
        }
        Update: {
          code?: string
          description?: string
          rank?: number
        }
        Relationships: []
      }
      item: {
        Row: {
          applies_to_version_ids: string[]
          assurance_level: string
          created_at: string
          created_by_receipt_id: string
          id: string
          kind: string
          payload: Json
          provenance_claim_id: string | null
          scope: Json
          source_node_id: string | null
          statement: string
          tenant_id: string
          title: string
        }
        Insert: {
          applies_to_version_ids?: string[]
          assurance_level?: string
          created_at?: string
          created_by_receipt_id: string
          id?: string
          kind: string
          payload?: Json
          provenance_claim_id?: string | null
          scope?: Json
          source_node_id?: string | null
          statement: string
          tenant_id?: string
          title: string
        }
        Update: {
          applies_to_version_ids?: string[]
          assurance_level?: string
          created_at?: string
          created_by_receipt_id?: string
          id?: string
          kind?: string
          payload?: Json
          provenance_claim_id?: string | null
          scope?: Json
          source_node_id?: string | null
          statement?: string
          tenant_id?: string
          title?: string
        }
        Relationships: [
          {
            foreignKeyName: "item_kind_fkey"
            columns: ["kind"]
            isOneToOne: false
            referencedRelation: "item_kind"
            referencedColumns: ["code"]
          },
          {
            foreignKeyName: "record_assurance_level_fkey"
            columns: ["assurance_level"]
            isOneToOne: false
            referencedRelation: "assurance_level"
            referencedColumns: ["code"]
          },
        ]
      }
      item_kind: {
        Row: {
          code: string
          description: string
          payload_schema: Json
        }
        Insert: {
          code: string
          description: string
          payload_schema?: Json
        }
        Update: {
          code?: string
          description?: string
          payload_schema?: Json
        }
        Relationships: []
      }
      item_subject: {
        Row: {
          entity_id: string
          item_id: string
          role: string
          tenant_id: string
        }
        Insert: {
          entity_id: string
          item_id: string
          role: string
          tenant_id?: string
        }
        Update: {
          entity_id?: string
          item_id?: string
          role?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "record_entity_link_record_id_fkey"
            columns: ["item_id"]
            isOneToOne: false
            referencedRelation: "item"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "record_entity_link_tenant_id_record_id_fkey"
            columns: ["tenant_id", "item_id"]
            isOneToOne: false
            referencedRelation: "item"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      maturity: "experimental" | "emerging" | "established" | "declining"
      revalidation_state:
        | "fresh"
        | "due"
        | "in_progress"
        | "stale"
        | "failed"
        | "retired"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  inquiry: {
    Tables: {
      acceptance: {
        Row: {
          acceptance_no: number
          accepted_by: string
          accepted_event_id: string
          brief_revision_id: string
          brief_work_id: string
          budget_limit_usd: number
          budget_policy: Json
          created_at: string
          execution_origin: string
          id: string
          knowledge_policy: string
          mc_application_id: string | null
          mc_installation_id: string | null
          mc_mission_id: string | null
          mc_revision_id: string | null
          mc_run_id: string | null
          revises_acceptance_id: string | null
          spent_usd: number
          state: string
          state_changed_at: string
          tenant_id: string
          workspace_id: string
          world_from: string | null
          world_precision: string
          world_to: string | null
        }
        Insert: {
          acceptance_no: number
          accepted_by: string
          accepted_event_id: string
          brief_revision_id: string
          brief_work_id: string
          budget_limit_usd: number
          budget_policy?: Json
          created_at?: string
          execution_origin: string
          id?: string
          knowledge_policy: string
          mc_application_id?: string | null
          mc_installation_id?: string | null
          mc_mission_id?: string | null
          mc_revision_id?: string | null
          mc_run_id?: string | null
          revises_acceptance_id?: string | null
          spent_usd?: number
          state?: string
          state_changed_at?: string
          tenant_id: string
          workspace_id: string
          world_from?: string | null
          world_precision?: string
          world_to?: string | null
        }
        Update: {
          acceptance_no?: number
          accepted_by?: string
          accepted_event_id?: string
          brief_revision_id?: string
          brief_work_id?: string
          budget_limit_usd?: number
          budget_policy?: Json
          created_at?: string
          execution_origin?: string
          id?: string
          knowledge_policy?: string
          mc_application_id?: string | null
          mc_installation_id?: string | null
          mc_mission_id?: string | null
          mc_revision_id?: string | null
          mc_run_id?: string | null
          revises_acceptance_id?: string | null
          spent_usd?: number
          state?: string
          state_changed_at?: string
          tenant_id?: string
          workspace_id?: string
          world_from?: string | null
          world_precision?: string
          world_to?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "acceptance_tenant_id_workspace_id_revises_acceptance_id_fkey"
            columns: ["tenant_id", "workspace_id", "revises_acceptance_id"]
            isOneToOne: false
            referencedRelation: "acceptance"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
        ]
      }
      assertion: {
        Row: {
          assertion_key: string
          block_key: string | null
          created_at: string
          created_by: string
          entity_ids: string[]
          id: string
          kind: string
          promoted_claim_id: string | null
          revision_id: string
          statement: string
          structured: Json | null
          support_status: string
          tenant_id: string
          uses_claim_id: string | null
          workspace_id: string
          world_from: string | null
          world_precision: string
          world_to: string | null
        }
        Insert: {
          assertion_key: string
          block_key?: string | null
          created_at?: string
          created_by: string
          entity_ids?: string[]
          id?: string
          kind: string
          promoted_claim_id?: string | null
          revision_id: string
          statement: string
          structured?: Json | null
          support_status: string
          tenant_id: string
          uses_claim_id?: string | null
          workspace_id: string
          world_from?: string | null
          world_precision?: string
          world_to?: string | null
        }
        Update: {
          assertion_key?: string
          block_key?: string | null
          created_at?: string
          created_by?: string
          entity_ids?: string[]
          id?: string
          kind?: string
          promoted_claim_id?: string | null
          revision_id?: string
          statement?: string
          structured?: Json | null
          support_status?: string
          tenant_id?: string
          uses_claim_id?: string | null
          workspace_id?: string
          world_from?: string | null
          world_precision?: string
          world_to?: string | null
        }
        Relationships: []
      }
      delivery: {
        Row: {
          artifact_id: string | null
          assessment: Json
          created_at: string
          decided_at: string | null
          decided_by: string | null
          decided_event_id: string | null
          delivered_by: string
          delivered_event_id: string
          delivered_kind: string
          file_set_id: string | null
          id: string
          mc_output_revision_id: string | null
          obligation_id: string
          origin: string
          revision_id: string | null
          state: string
          tenant_id: string
          workspace_id: string
        }
        Insert: {
          artifact_id?: string | null
          assessment?: Json
          created_at?: string
          decided_at?: string | null
          decided_by?: string | null
          decided_event_id?: string | null
          delivered_by: string
          delivered_event_id: string
          delivered_kind: string
          file_set_id?: string | null
          id?: string
          mc_output_revision_id?: string | null
          obligation_id: string
          origin: string
          revision_id?: string | null
          state?: string
          tenant_id: string
          workspace_id: string
        }
        Update: {
          artifact_id?: string | null
          assessment?: Json
          created_at?: string
          decided_at?: string | null
          decided_by?: string | null
          decided_event_id?: string | null
          delivered_by?: string
          delivered_event_id?: string
          delivered_kind?: string
          file_set_id?: string | null
          id?: string
          mc_output_revision_id?: string | null
          obligation_id?: string
          origin?: string
          revision_id?: string | null
          state?: string
          tenant_id?: string
          workspace_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "delivery_tenant_id_workspace_id_obligation_id_fkey"
            columns: ["tenant_id", "workspace_id", "obligation_id"]
            isOneToOne: false
            referencedRelation: "obligation"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
        ]
      }
      obligation: {
        Row: {
          acceptance_id: string
          criteria: Json
          enforcement: string
          expected_work_kind: string | null
          form: string
          id: string
          mc_obligation_key: string | null
          obligation_key: string
          position: number
          tenant_id: string
          workspace_id: string
        }
        Insert: {
          acceptance_id: string
          criteria?: Json
          enforcement: string
          expected_work_kind?: string | null
          form: string
          id?: string
          mc_obligation_key?: string | null
          obligation_key: string
          position: number
          tenant_id: string
          workspace_id: string
        }
        Update: {
          acceptance_id?: string
          criteria?: Json
          enforcement?: string
          expected_work_kind?: string | null
          form?: string
          id?: string
          mc_obligation_key?: string | null
          obligation_key?: string
          position?: number
          tenant_id?: string
          workspace_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "obligation_tenant_id_workspace_id_acceptance_id_fkey"
            columns: ["tenant_id", "workspace_id", "acceptance_id"]
            isOneToOne: false
            referencedRelation: "acceptance"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
        ]
      }
      support: {
        Row: {
          answer_key: string | null
          assertion_id: string | null
          assessed_at: string
          assessed_by: string
          assessed_kind: string
          capture_id: string | null
          cell_id: string | null
          claim_id: string | null
          dataset_work_id: string | null
          decision_revision_id: string | null
          excerpt: string | null
          field_key: string | null
          id: string
          locator_id: string | null
          method: Json | null
          record_id: string | null
          role: string
          row_key: string | null
          selector: Json | null
          source_revision_id: string | null
          target_assertion_id: string | null
          target_cell_id: string | null
          tenant_id: string
          verification_ref: string | null
          workspace_id: string
        }
        Insert: {
          answer_key?: string | null
          assertion_id?: string | null
          assessed_at?: string
          assessed_by: string
          assessed_kind: string
          capture_id?: string | null
          cell_id?: string | null
          claim_id?: string | null
          dataset_work_id?: string | null
          decision_revision_id?: string | null
          excerpt?: string | null
          field_key?: string | null
          id?: string
          locator_id?: string | null
          method?: Json | null
          record_id?: string | null
          role: string
          row_key?: string | null
          selector?: Json | null
          source_revision_id?: string | null
          target_assertion_id?: string | null
          target_cell_id?: string | null
          tenant_id: string
          verification_ref?: string | null
          workspace_id: string
        }
        Update: {
          answer_key?: string | null
          assertion_id?: string | null
          assessed_at?: string
          assessed_by?: string
          assessed_kind?: string
          capture_id?: string | null
          cell_id?: string | null
          claim_id?: string | null
          dataset_work_id?: string | null
          decision_revision_id?: string | null
          excerpt?: string | null
          field_key?: string | null
          id?: string
          locator_id?: string | null
          method?: Json | null
          record_id?: string | null
          role?: string
          row_key?: string | null
          selector?: Json | null
          source_revision_id?: string | null
          target_assertion_id?: string | null
          target_cell_id?: string | null
          tenant_id?: string
          verification_ref?: string | null
          workspace_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "support_tenant_id_workspace_id_assertion_id_fkey"
            columns: ["tenant_id", "workspace_id", "assertion_id"]
            isOneToOne: false
            referencedRelation: "assertion"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
          {
            foreignKeyName: "support_tenant_id_workspace_id_target_assertion_id_fkey"
            columns: ["tenant_id", "workspace_id", "target_assertion_id"]
            isOneToOne: false
            referencedRelation: "assertion"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
        ]
      }
      watch: {
        Row: {
          brief_work_id: string
          budget_per_run_usd: number
          budget_total_usd: number
          cadence: string
          created_at: string
          created_by: string
          id: string
          mc_schedule_ref: string | null
          sources: Json
          state: string
          state_changed_at: string
          stop_condition: Json
          subjects: Json
          target_work_ids: string[]
          tenant_id: string
          workspace_id: string
        }
        Insert: {
          brief_work_id: string
          budget_per_run_usd: number
          budget_total_usd: number
          cadence: string
          created_at?: string
          created_by: string
          id?: string
          mc_schedule_ref?: string | null
          sources: Json
          state?: string
          state_changed_at?: string
          stop_condition?: Json
          subjects: Json
          target_work_ids?: string[]
          tenant_id: string
          workspace_id: string
        }
        Update: {
          brief_work_id?: string
          budget_per_run_usd?: number
          budget_total_usd?: number
          cadence?: string
          created_at?: string
          created_by?: string
          id?: string
          mc_schedule_ref?: string | null
          sources?: Json
          state?: string
          state_changed_at?: string
          stop_condition?: Json
          subjects?: Json
          target_work_ids?: string[]
          tenant_id?: string
          workspace_id?: string
        }
        Relationships: []
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  knowledge_service: {
    Tables: {
      callback_delivery: {
        Row: {
          callback_id: string
          causation_id: string | null
          correlation_id: string
          occurred_at: string
          operation_id: string
          payload_sha256: string
          received_at: string
          receiver_identity: string
          signature: string
          signing_key_reference: string
          task_id: string
          tenant_id: string
        }
        Insert: {
          callback_id: string
          causation_id?: string | null
          correlation_id: string
          occurred_at: string
          operation_id: string
          payload_sha256: string
          received_at?: string
          receiver_identity: string
          signature: string
          signing_key_reference: string
          task_id: string
          tenant_id?: string
        }
        Update: {
          callback_id?: string
          causation_id?: string | null
          correlation_id?: string
          occurred_at?: string
          operation_id?: string
          payload_sha256?: string
          received_at?: string
          receiver_identity?: string
          signature?: string
          signing_key_reference?: string
          task_id?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "callback_delivery_tenant_id_operation_id_fkey"
            columns: ["tenant_id", "operation_id"]
            isOneToOne: false
            referencedRelation: "operation"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      checkpoint_artifact_reference: {
        Row: {
          artifact_id: string
          checkpoint_id: string
          tenant_id: string
        }
        Insert: {
          artifact_id: string
          checkpoint_id: string
          tenant_id: string
        }
        Update: {
          artifact_id?: string
          checkpoint_id?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "checkpoint_artifact_reference_tenant_id_checkpoint_id_fkey"
            columns: ["tenant_id", "checkpoint_id"]
            isOneToOne: false
            referencedRelation: "scoped_checkpoint"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      checkpoint_scope: {
        Row: {
          created_at: string
          head_checkpoint_id: string | null
          id: string
          parent_scope_id: string | null
          revision: number
          scope: Json
          tenant_id: string
        }
        Insert: {
          created_at?: string
          head_checkpoint_id?: string | null
          id: string
          parent_scope_id?: string | null
          revision?: number
          scope: Json
          tenant_id: string
        }
        Update: {
          created_at?: string
          head_checkpoint_id?: string | null
          id?: string
          parent_scope_id?: string | null
          revision?: number
          scope?: Json
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "checkpoint_scope_head_fk"
            columns: ["tenant_id", "id", "head_checkpoint_id"]
            isOneToOne: false
            referencedRelation: "scoped_checkpoint"
            referencedColumns: ["tenant_id", "scope_id", "id"]
          },
          {
            foreignKeyName: "checkpoint_scope_tenant_id_parent_scope_id_fkey"
            columns: ["tenant_id", "parent_scope_id"]
            isOneToOne: false
            referencedRelation: "checkpoint_scope"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      eve_operation_binding: {
        Row: {
          actor_identity: string
          agent_deployment_id: string
          attempt_id: string
          capability_version: string
          created_at: string
          grant_id: string
          idempotency_key: string
          issuer: string
          mission_id: string
          operation_id: string
          original_external_execution: Json
          original_jti: string
          original_key_id: string
          original_payload_sha256: string
          request_sha256: string
          tenant_id: string
          use_case: string
          work_item_id: string
        }
        Insert: {
          actor_identity: string
          agent_deployment_id: string
          attempt_id: string
          capability_version: string
          created_at?: string
          grant_id: string
          idempotency_key: string
          issuer: string
          mission_id: string
          operation_id: string
          original_external_execution: Json
          original_jti: string
          original_key_id: string
          original_payload_sha256: string
          request_sha256: string
          tenant_id?: string
          use_case: string
          work_item_id: string
        }
        Update: {
          actor_identity?: string
          agent_deployment_id?: string
          attempt_id?: string
          capability_version?: string
          created_at?: string
          grant_id?: string
          idempotency_key?: string
          issuer?: string
          mission_id?: string
          operation_id?: string
          original_external_execution?: Json
          original_jti?: string
          original_key_id?: string
          original_payload_sha256?: string
          request_sha256?: string
          tenant_id?: string
          use_case?: string
          work_item_id?: string
        }
        Relationships: []
      }
      eve_operation_invocation: {
        Row: {
          accepted_at: string
          envelope: Json
          envelope_sha256: string
          expires_at: string
          id: string
          invocation_kind: string
          issued_at: string
          issuer: string
          jti: string
          key_id: string
          lineage_sha256: string
          observed_external_execution: Json
          operation_id: string
          tenant_id: string
        }
        Insert: {
          accepted_at?: string
          envelope: Json
          envelope_sha256: string
          expires_at: string
          id?: string
          invocation_kind: string
          issued_at: string
          issuer: string
          jti: string
          key_id: string
          lineage_sha256: string
          observed_external_execution: Json
          operation_id: string
          tenant_id?: string
        }
        Update: {
          accepted_at?: string
          envelope?: Json
          envelope_sha256?: string
          expires_at?: string
          id?: string
          invocation_kind?: string
          issued_at?: string
          issuer?: string
          jti?: string
          key_id?: string
          lineage_sha256?: string
          observed_external_execution?: Json
          operation_id?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "eve_operation_invocation_tenant_id_operation_id_fkey"
            columns: ["tenant_id", "operation_id"]
            isOneToOne: false
            referencedRelation: "eve_operation_binding"
            referencedColumns: ["tenant_id", "operation_id"]
          },
        ]
      }
      lease: {
        Row: {
          acquired_at: string
          expires_at: string
          fencing_token: number
          heartbeat_at: string
          holder_identity: string
          id: string
          lease_token: string
          operation_step_id: string
          released_at: string | null
          tenant_id: string
        }
        Insert: {
          acquired_at?: string
          expires_at: string
          fencing_token?: never
          heartbeat_at?: string
          holder_identity: string
          id?: string
          lease_token?: string
          operation_step_id: string
          released_at?: string | null
          tenant_id?: string
        }
        Update: {
          acquired_at?: string
          expires_at?: string
          fencing_token?: never
          heartbeat_at?: string
          holder_identity?: string
          id?: string
          lease_token?: string
          operation_step_id?: string
          released_at?: string | null
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "lease_tenant_id_operation_step_id_fkey"
            columns: ["tenant_id", "operation_step_id"]
            isOneToOne: true
            referencedRelation: "operation_step"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      operation: {
        Row: {
          actor_identity: string
          attempt_id: string | null
          capability_version_id: string | null
          causation_id: string | null
          completed_at: string | null
          correlation_id: string
          created_at: string
          external_run_id: string | null
          id: string
          idempotency_key: string
          mission_id: string | null
          operation_kind: string
          ownership_mode: string
          request: Json
          request_sha256: string
          row_version: number
          status: string
          tenant_id: string
          updated_at: string
          work_item_id: string | null
        }
        Insert: {
          actor_identity: string
          attempt_id?: string | null
          capability_version_id?: string | null
          causation_id?: string | null
          completed_at?: string | null
          correlation_id: string
          created_at?: string
          external_run_id?: string | null
          id?: string
          idempotency_key: string
          mission_id?: string | null
          operation_kind: string
          ownership_mode?: string
          request: Json
          request_sha256: string
          row_version?: number
          status?: string
          tenant_id?: string
          updated_at?: string
          work_item_id?: string | null
        }
        Update: {
          actor_identity?: string
          attempt_id?: string | null
          capability_version_id?: string | null
          causation_id?: string | null
          completed_at?: string | null
          correlation_id?: string
          created_at?: string
          external_run_id?: string | null
          id?: string
          idempotency_key?: string
          mission_id?: string | null
          operation_kind?: string
          ownership_mode?: string
          request?: Json
          request_sha256?: string
          row_version?: number
          status?: string
          tenant_id?: string
          updated_at?: string
          work_item_id?: string | null
        }
        Relationships: []
      }
      operation_event: {
        Row: {
          actor_identity: string
          causation_id: string | null
          correlation_id: string
          event_kind: string
          from_state: string | null
          guarded_sha256: string | null
          id: string
          occurred_at: string
          operation_id: string
          payload: Json
          step_id: string | null
          tenant_id: string
          to_state: string | null
        }
        Insert: {
          actor_identity: string
          causation_id?: string | null
          correlation_id: string
          event_kind: string
          from_state?: string | null
          guarded_sha256?: string | null
          id?: string
          occurred_at?: string
          operation_id: string
          payload?: Json
          step_id?: string | null
          tenant_id?: string
          to_state?: string | null
        }
        Update: {
          actor_identity?: string
          causation_id?: string | null
          correlation_id?: string
          event_kind?: string
          from_state?: string | null
          guarded_sha256?: string | null
          id?: string
          occurred_at?: string
          operation_id?: string
          payload?: Json
          step_id?: string | null
          tenant_id?: string
          to_state?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "operation_event_tenant_id_operation_id_fkey"
            columns: ["tenant_id", "operation_id"]
            isOneToOne: false
            referencedRelation: "operation"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "operation_event_tenant_id_step_id_fkey"
            columns: ["tenant_id", "step_id"]
            isOneToOne: false
            referencedRelation: "operation_step"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      operation_step: {
        Row: {
          attempt_count: number
          available_at: string
          completed_at: string | null
          created_at: string
          id: string
          input: Json
          input_sha256: string
          max_attempts: number
          operation_id: string
          row_version: number
          status: string
          step_key: string
          step_kind: string
          tenant_id: string
          updated_at: string
        }
        Insert: {
          attempt_count?: number
          available_at?: string
          completed_at?: string | null
          created_at?: string
          id?: string
          input: Json
          input_sha256: string
          max_attempts?: number
          operation_id: string
          row_version?: number
          status?: string
          step_key: string
          step_kind: string
          tenant_id?: string
          updated_at?: string
        }
        Update: {
          attempt_count?: number
          available_at?: string
          completed_at?: string | null
          created_at?: string
          id?: string
          input?: Json
          input_sha256?: string
          max_attempts?: number
          operation_id?: string
          row_version?: number
          status?: string
          step_key?: string
          step_kind?: string
          tenant_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "operation_step_tenant_id_operation_id_fkey"
            columns: ["tenant_id", "operation_id"]
            isOneToOne: false
            referencedRelation: "operation"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      outbox: {
        Row: {
          archived_at: string | null
          available_at: string
          claim_owner: string | null
          claim_token: string | null
          claimed_at: string | null
          created_at: string
          delivery_attempts: number
          event_id: string
          id: string
          last_error: string | null
          max_delivery_attempts: number
          operation_id: string
          payload: Json
          payload_sha256: string
          published_at: string | null
          tenant_id: string
          topic: string
          visibility_expires_at: string | null
        }
        Insert: {
          archived_at?: string | null
          available_at?: string
          claim_owner?: string | null
          claim_token?: string | null
          claimed_at?: string | null
          created_at?: string
          delivery_attempts?: number
          event_id: string
          id?: string
          last_error?: string | null
          max_delivery_attempts?: number
          operation_id: string
          payload: Json
          payload_sha256: string
          published_at?: string | null
          tenant_id?: string
          topic: string
          visibility_expires_at?: string | null
        }
        Update: {
          archived_at?: string | null
          available_at?: string
          claim_owner?: string | null
          claim_token?: string | null
          claimed_at?: string | null
          created_at?: string
          delivery_attempts?: number
          event_id?: string
          id?: string
          last_error?: string | null
          max_delivery_attempts?: number
          operation_id?: string
          payload?: Json
          payload_sha256?: string
          published_at?: string | null
          tenant_id?: string
          topic?: string
          visibility_expires_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "outbox_event_operation_fk"
            columns: ["tenant_id", "event_id", "operation_id"]
            isOneToOne: false
            referencedRelation: "operation_event"
            referencedColumns: ["tenant_id", "id", "operation_id"]
          },
          {
            foreignKeyName: "outbox_tenant_id_event_id_fkey"
            columns: ["tenant_id", "event_id"]
            isOneToOne: false
            referencedRelation: "operation_event"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "outbox_tenant_id_operation_id_fkey"
            columns: ["tenant_id", "operation_id"]
            isOneToOne: false
            referencedRelation: "operation"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      receipt: {
        Row: {
          body: Json
          created_at: string
          executor_identity: string
          id: string
          idempotency_key: string
          input_sha256: string
          operation_id: string
          outcome: string
          output_sha256: string | null
          receipt_kind: string
          signature: string | null
          step_id: string | null
          tenant_id: string
        }
        Insert: {
          body: Json
          created_at?: string
          executor_identity: string
          id?: string
          idempotency_key: string
          input_sha256: string
          operation_id: string
          outcome: string
          output_sha256?: string | null
          receipt_kind: string
          signature?: string | null
          step_id?: string | null
          tenant_id?: string
        }
        Update: {
          body?: Json
          created_at?: string
          executor_identity?: string
          id?: string
          idempotency_key?: string
          input_sha256?: string
          operation_id?: string
          outcome?: string
          output_sha256?: string | null
          receipt_kind?: string
          signature?: string | null
          step_id?: string | null
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "receipt_tenant_id_operation_id_fkey"
            columns: ["tenant_id", "operation_id"]
            isOneToOne: false
            referencedRelation: "operation"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "receipt_tenant_id_step_id_fkey"
            columns: ["tenant_id", "step_id"]
            isOneToOne: false
            referencedRelation: "operation_step"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      review_decision: {
        Row: {
          created_at: string
          decision: string
          decision_operation_id: string | null
          guarded_sha256: string
          id: string
          legacy_provenance: boolean
          rationale: string
          review_subject_id: string
          reviewer_identity: string
          reviewer_role: string
          tenant_id: string
        }
        Insert: {
          created_at?: string
          decision: string
          decision_operation_id?: string | null
          guarded_sha256: string
          id?: string
          legacy_provenance?: boolean
          rationale: string
          review_subject_id: string
          reviewer_identity: string
          reviewer_role: string
          tenant_id?: string
        }
        Update: {
          created_at?: string
          decision?: string
          decision_operation_id?: string | null
          guarded_sha256?: string
          id?: string
          legacy_provenance?: boolean
          rationale?: string
          review_subject_id?: string
          reviewer_identity?: string
          reviewer_role?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "review_decision_operation_fk"
            columns: ["tenant_id", "decision_operation_id"]
            isOneToOne: false
            referencedRelation: "operation"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "review_decision_tenant_id_review_subject_id_fkey"
            columns: ["tenant_id", "review_subject_id"]
            isOneToOne: false
            referencedRelation: "review_subject"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      review_subject: {
        Row: {
          created_at: string
          eligible_roles: string[]
          expires_at: string | null
          guarded_sha256: string
          id: string
          operation_id: string
          quorum_required: number
          subject_kind: string
          subject_ref: Json
          tenant_id: string
        }
        Insert: {
          created_at?: string
          eligible_roles: string[]
          expires_at?: string | null
          guarded_sha256: string
          id?: string
          operation_id: string
          quorum_required?: number
          subject_kind: string
          subject_ref: Json
          tenant_id?: string
        }
        Update: {
          created_at?: string
          eligible_roles?: string[]
          expires_at?: string | null
          guarded_sha256?: string
          id?: string
          operation_id?: string
          quorum_required?: number
          subject_kind?: string
          subject_ref?: Json
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "review_subject_tenant_id_operation_id_fkey"
            columns: ["tenant_id", "operation_id"]
            isOneToOne: false
            referencedRelation: "operation"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      scoped_checkpoint: {
        Row: {
          committed_at: string
          harness_request_digest: string | null
          id: string
          idempotency_key: string
          manifest_artifact_id: string
          manifest_handle: Json
          mode: string
          parent_checkpoint_id: string | null
          request_digest: string
          revision: number
          scope_id: string
          tenant_id: string
        }
        Insert: {
          committed_at?: string
          harness_request_digest?: string | null
          id: string
          idempotency_key: string
          manifest_artifact_id: string
          manifest_handle: Json
          mode: string
          parent_checkpoint_id?: string | null
          request_digest: string
          revision: number
          scope_id: string
          tenant_id: string
        }
        Update: {
          committed_at?: string
          harness_request_digest?: string | null
          id?: string
          idempotency_key?: string
          manifest_artifact_id?: string
          manifest_handle?: Json
          mode?: string
          parent_checkpoint_id?: string | null
          request_digest?: string
          revision?: number
          scope_id?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "scoped_checkpoint_tenant_id_scope_id_fkey"
            columns: ["tenant_id", "scope_id"]
            isOneToOne: false
            referencedRelation: "checkpoint_scope"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "scoped_checkpoint_tenant_id_scope_id_parent_checkpoint_id_fkey"
            columns: ["tenant_id", "scope_id", "parent_checkpoint_id"]
            isOneToOne: false
            referencedRelation: "scoped_checkpoint"
            referencedColumns: ["tenant_id", "scope_id", "id"]
          },
        ]
      }
      verification_component_binding: {
        Row: {
          bound_at: string
          component: string
          component_version: string
          migration_keys: string[]
          singleton: boolean
        }
        Insert: {
          bound_at?: string
          component: string
          component_version: string
          migration_keys: string[]
          singleton?: boolean
        }
        Update: {
          bound_at?: string
          component?: string
          component_version?: string
          migration_keys?: string[]
          singleton?: boolean
        }
        Relationships: []
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      ack_outbox: {
        Args: {
          p_claim_owner: string
          p_claim_token: string
          p_outbox_id: string
        }
        Returns: boolean
      }
      claim_outbox: {
        Args: {
          p_claim_owner: string
          p_limit?: number
          p_operation_id?: string
          p_visibility_timeout_ms?: number
        }
        Returns: {
          claim_owner: string
          claim_token: string
          claimed_at: string
          delivery_attempts: number
          event_id: string
          id: string
          operation_id: string
          payload: Json
          payload_sha256: string
          topic: string
          visibility_expires_at: string
        }[]
      }
      extend_outbox_claim: {
        Args: {
          p_claim_owner: string
          p_claim_token: string
          p_outbox_id: string
          p_visibility_timeout_ms: number
        }
        Returns: string
      }
      nack_outbox: {
        Args: {
          p_claim_owner: string
          p_claim_token: string
          p_error_class: string
          p_outbox_id: string
          p_retry_delay_ms?: number
        }
        Returns: boolean
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  learning: {
    Tables: {
      appeal: {
        Row: {
          created_at: string
          grounds: string
          id: string
          learner_id: string
          new_evidence_submission_id: string | null
          resolution: string | null
          resolution_result_id: string | null
          resolved_at: string | null
          result_id: string
          reviewer_id: string | null
          state: string
          tenant_id: string
          workspace_id: string
        }
        Insert: {
          created_at?: string
          grounds: string
          id?: string
          learner_id: string
          new_evidence_submission_id?: string | null
          resolution?: string | null
          resolution_result_id?: string | null
          resolved_at?: string | null
          result_id: string
          reviewer_id?: string | null
          state: string
          tenant_id: string
          workspace_id: string
        }
        Update: {
          created_at?: string
          grounds?: string
          id?: string
          learner_id?: string
          new_evidence_submission_id?: string | null
          resolution?: string | null
          resolution_result_id?: string | null
          resolved_at?: string | null
          result_id?: string
          reviewer_id?: string | null
          state?: string
          tenant_id?: string
          workspace_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "appeal_tenant_id_workspace_id_new_evidence_submission_id_fkey"
            columns: ["tenant_id", "workspace_id", "new_evidence_submission_id"]
            isOneToOne: false
            referencedRelation: "submission"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
          {
            foreignKeyName: "appeal_tenant_id_workspace_id_resolution_result_id_fkey"
            columns: ["tenant_id", "workspace_id", "resolution_result_id"]
            isOneToOne: false
            referencedRelation: "assessment_result"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
          {
            foreignKeyName: "appeal_tenant_id_workspace_id_result_id_fkey"
            columns: ["tenant_id", "workspace_id", "result_id"]
            isOneToOne: false
            referencedRelation: "assessment_result"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
        ]
      }
      assessment_result: {
        Row: {
          created_at: string
          explanation_artifact_id: string | null
          finalization_policy_revision_id: string | null
          finalized_at: string | null
          finalized_by: string | null
          id: string
          outcomes: Json
          reason: string
          sequence_no: number
          status: string
          submission_id: string
          supersedes_id: string | null
          tenant_id: string
          workspace_id: string
        }
        Insert: {
          created_at?: string
          explanation_artifact_id?: string | null
          finalization_policy_revision_id?: string | null
          finalized_at?: string | null
          finalized_by?: string | null
          id?: string
          outcomes: Json
          reason: string
          sequence_no: number
          status: string
          submission_id: string
          supersedes_id?: string | null
          tenant_id: string
          workspace_id: string
        }
        Update: {
          created_at?: string
          explanation_artifact_id?: string | null
          finalization_policy_revision_id?: string | null
          finalized_at?: string | null
          finalized_by?: string | null
          id?: string
          outcomes?: Json
          reason?: string
          sequence_no?: number
          status?: string
          submission_id?: string
          supersedes_id?: string | null
          tenant_id?: string
          workspace_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "assessment_result_tenant_id_workspace_id_submission_id_fkey"
            columns: ["tenant_id", "workspace_id", "submission_id"]
            isOneToOne: false
            referencedRelation: "submission"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
          {
            foreignKeyName: "assessment_result_tenant_id_workspace_id_supersedes_id_fkey"
            columns: ["tenant_id", "workspace_id", "supersedes_id"]
            isOneToOne: false
            referencedRelation: "assessment_result"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
        ]
      }
      attempt: {
        Row: {
          active_seconds: number | null
          active_seconds_source: string | null
          adoption_id: string | null
          conditions: Json
          ended_at: string | null
          enrollment_id: string | null
          environment_session_id: string | null
          equivalence_request_id: string | null
          id: string
          learner_id: string
          mastery_decision_id: string | null
          option_id: string | null
          previous_attempt_id: string | null
          purpose: string
          requirement_key: string | null
          started_at: string
          state: string
          task_release_item_id: string | null
          task_revision_id: string | null
          tenant_id: string
          workspace_id: string
        }
        Insert: {
          active_seconds?: number | null
          active_seconds_source?: string | null
          adoption_id?: string | null
          conditions: Json
          ended_at?: string | null
          enrollment_id?: string | null
          environment_session_id?: string | null
          equivalence_request_id?: string | null
          id?: string
          learner_id: string
          mastery_decision_id?: string | null
          option_id?: string | null
          previous_attempt_id?: string | null
          purpose: string
          requirement_key?: string | null
          started_at?: string
          state?: string
          task_release_item_id?: string | null
          task_revision_id?: string | null
          tenant_id: string
          workspace_id: string
        }
        Update: {
          active_seconds?: number | null
          active_seconds_source?: string | null
          adoption_id?: string | null
          conditions?: Json
          ended_at?: string | null
          enrollment_id?: string | null
          environment_session_id?: string | null
          equivalence_request_id?: string | null
          id?: string
          learner_id?: string
          mastery_decision_id?: string | null
          option_id?: string | null
          previous_attempt_id?: string | null
          purpose?: string
          requirement_key?: string | null
          started_at?: string
          state?: string
          task_release_item_id?: string | null
          task_revision_id?: string | null
          tenant_id?: string
          workspace_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "attempt_tenant_id_workspace_id_enrollment_id_adoption_id_fkey"
            columns: [
              "tenant_id",
              "workspace_id",
              "enrollment_id",
              "adoption_id",
            ]
            isOneToOne: false
            referencedRelation: "release_adoption"
            referencedColumns: [
              "tenant_id",
              "workspace_id",
              "enrollment_id",
              "id",
            ]
          },
          {
            foreignKeyName: "attempt_tenant_id_workspace_id_enrollment_id_fkey"
            columns: ["tenant_id", "workspace_id", "enrollment_id"]
            isOneToOne: false
            referencedRelation: "enrollment"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
          {
            foreignKeyName: "attempt_tenant_id_workspace_id_environment_session_id_fkey"
            columns: ["tenant_id", "workspace_id", "environment_session_id"]
            isOneToOne: false
            referencedRelation: "environment_session"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
          {
            foreignKeyName: "attempt_tenant_id_workspace_id_equivalence_request_id_fkey"
            columns: ["tenant_id", "workspace_id", "equivalence_request_id"]
            isOneToOne: false
            referencedRelation: "equivalence_request"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
          {
            foreignKeyName: "attempt_tenant_id_workspace_id_mastery_decision_id_fkey"
            columns: ["tenant_id", "workspace_id", "mastery_decision_id"]
            isOneToOne: false
            referencedRelation: "mastery_decision"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
          {
            foreignKeyName: "attempt_tenant_id_workspace_id_previous_attempt_id_fkey"
            columns: ["tenant_id", "workspace_id", "previous_attempt_id"]
            isOneToOne: false
            referencedRelation: "attempt"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
        ]
      }
      credit: {
        Row: {
          adoption_id: string
          carried_from_credit_id: string | null
          created_at: string
          ended_at: string | null
          enrollment_id: string
          facet: string
          id: string
          learner_id: string
          requirement_id: string
          result_id: string | null
          route: string
          status: string
          status_reason: string | null
          tenant_id: string
          transition_id: string | null
          workspace_id: string
        }
        Insert: {
          adoption_id: string
          carried_from_credit_id?: string | null
          created_at?: string
          ended_at?: string | null
          enrollment_id: string
          facet: string
          id?: string
          learner_id: string
          requirement_id: string
          result_id?: string | null
          route: string
          status: string
          status_reason?: string | null
          tenant_id: string
          transition_id?: string | null
          workspace_id: string
        }
        Update: {
          adoption_id?: string
          carried_from_credit_id?: string | null
          created_at?: string
          ended_at?: string | null
          enrollment_id?: string
          facet?: string
          id?: string
          learner_id?: string
          requirement_id?: string
          result_id?: string | null
          route?: string
          status?: string
          status_reason?: string | null
          tenant_id?: string
          transition_id?: string | null
          workspace_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "credit_tenant_id_workspace_id_carried_from_credit_id_fkey"
            columns: ["tenant_id", "workspace_id", "carried_from_credit_id"]
            isOneToOne: false
            referencedRelation: "credit"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
          {
            foreignKeyName: "credit_tenant_id_workspace_id_enrollment_id_adoption_id_fkey"
            columns: [
              "tenant_id",
              "workspace_id",
              "enrollment_id",
              "adoption_id",
            ]
            isOneToOne: false
            referencedRelation: "release_adoption"
            referencedColumns: [
              "tenant_id",
              "workspace_id",
              "enrollment_id",
              "id",
            ]
          },
          {
            foreignKeyName: "credit_tenant_id_workspace_id_result_id_fkey"
            columns: ["tenant_id", "workspace_id", "result_id"]
            isOneToOne: false
            referencedRelation: "assessment_result"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
        ]
      }
      criterion_result: {
        Row: {
          created_at: string
          criterion_key: string
          evidence_refs: Json
          explanation: string
          grading_run_id: string
          id: string
          judged_by: string
          judgment: Json | null
          reviewer_id: string | null
          tenant_id: string
          value: Json
          visibility: string
          workspace_id: string
        }
        Insert: {
          created_at?: string
          criterion_key: string
          evidence_refs?: Json
          explanation: string
          grading_run_id: string
          id?: string
          judged_by: string
          judgment?: Json | null
          reviewer_id?: string | null
          tenant_id: string
          value: Json
          visibility: string
          workspace_id: string
        }
        Update: {
          created_at?: string
          criterion_key?: string
          evidence_refs?: Json
          explanation?: string
          grading_run_id?: string
          id?: string
          judged_by?: string
          judgment?: Json | null
          reviewer_id?: string | null
          tenant_id?: string
          value?: Json
          visibility?: string
          workspace_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "criterion_result_tenant_id_workspace_id_grading_run_id_fkey"
            columns: ["tenant_id", "workspace_id", "grading_run_id"]
            isOneToOne: false
            referencedRelation: "grading_run"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
        ]
      }
      enrollment: {
        Row: {
          created_at: string
          distribution_id: string
          id: string
          learner_id: string
          source_workspace_id: string
          tenant_id: string
          update_policy: string
          workspace_id: string
        }
        Insert: {
          created_at?: string
          distribution_id: string
          id?: string
          learner_id: string
          source_workspace_id: string
          tenant_id: string
          update_policy?: string
          workspace_id: string
        }
        Update: {
          created_at?: string
          distribution_id?: string
          id?: string
          learner_id?: string
          source_workspace_id?: string
          tenant_id?: string
          update_policy?: string
          workspace_id?: string
        }
        Relationships: []
      }
      environment_session: {
        Row: {
          adapter: string | null
          created_at: string
          ended_at: string | null
          expires_at: string | null
          external_ref: Json | null
          id: string
          key_handles: Json
          learner_id: string
          project_work_id: string | null
          provider: string
          spec_revision_id: string | null
          spend_limit_usd: number | null
          spent_usd: number
          status: string
          tenant_id: string
          workspace_id: string
        }
        Insert: {
          adapter?: string | null
          created_at?: string
          ended_at?: string | null
          expires_at?: string | null
          external_ref?: Json | null
          id?: string
          key_handles?: Json
          learner_id: string
          project_work_id?: string | null
          provider: string
          spec_revision_id?: string | null
          spend_limit_usd?: number | null
          spent_usd?: number
          status: string
          tenant_id: string
          workspace_id: string
        }
        Update: {
          adapter?: string | null
          created_at?: string
          ended_at?: string | null
          expires_at?: string | null
          external_ref?: Json | null
          id?: string
          key_handles?: Json
          learner_id?: string
          project_work_id?: string | null
          provider?: string
          spec_revision_id?: string | null
          spend_limit_usd?: number | null
          spent_usd?: number
          status?: string
          tenant_id?: string
          workspace_id?: string
        }
        Relationships: []
      }
      equivalence_request: {
        Row: {
          assistant_check: Json | null
          created_at: string
          decided_at: string | null
          decided_by: string | null
          decision: string | null
          decision_reason: string | null
          enrollment_id: string
          evidence_plan: string
          id: string
          learner_id: string
          requirement_keys: string[]
          state: string
          tenant_id: string
          work_revision_id: string
          workspace_id: string
        }
        Insert: {
          assistant_check?: Json | null
          created_at?: string
          decided_at?: string | null
          decided_by?: string | null
          decision?: string | null
          decision_reason?: string | null
          enrollment_id: string
          evidence_plan: string
          id?: string
          learner_id: string
          requirement_keys: string[]
          state: string
          tenant_id: string
          work_revision_id: string
          workspace_id: string
        }
        Update: {
          assistant_check?: Json | null
          created_at?: string
          decided_at?: string | null
          decided_by?: string | null
          decision?: string | null
          decision_reason?: string | null
          enrollment_id?: string
          evidence_plan?: string
          id?: string
          learner_id?: string
          requirement_keys?: string[]
          state?: string
          tenant_id?: string
          work_revision_id?: string
          workspace_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "equivalence_request_tenant_id_workspace_id_enrollment_id_fkey"
            columns: ["tenant_id", "workspace_id", "enrollment_id"]
            isOneToOne: false
            referencedRelation: "enrollment"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
        ]
      }
      evidence_grant: {
        Row: {
          enrollment_id: string | null
          granted_at: string
          grantee_id: string
          guardian_link_id: string | null
          id: string
          includes: string[]
          learner_id: string
          revoked_at: string | null
          scope_kind: string
          tenant_id: string
          workspace_id: string
        }
        Insert: {
          enrollment_id?: string | null
          granted_at?: string
          grantee_id: string
          guardian_link_id?: string | null
          id?: string
          includes: string[]
          learner_id: string
          revoked_at?: string | null
          scope_kind: string
          tenant_id: string
          workspace_id: string
        }
        Update: {
          enrollment_id?: string | null
          granted_at?: string
          grantee_id?: string
          guardian_link_id?: string | null
          id?: string
          includes?: string[]
          learner_id?: string
          revoked_at?: string | null
          scope_kind?: string
          tenant_id?: string
          workspace_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "evidence_grant_tenant_id_workspace_id_enrollment_id_fkey"
            columns: ["tenant_id", "workspace_id", "enrollment_id"]
            isOneToOne: false
            referencedRelation: "enrollment"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
        ]
      }
      evidence_item: {
        Row: {
          artifact_id: string | null
          availability: string
          created_at: string
          deployment_id: string | null
          external_ref: Json | null
          file_set_id: string | null
          id: string
          item_key: string
          kind: string
          message_id: string | null
          revision_id: string | null
          sha256: string | null
          submission_id: string
          tenant_id: string
          workspace_id: string
        }
        Insert: {
          artifact_id?: string | null
          availability: string
          created_at?: string
          deployment_id?: string | null
          external_ref?: Json | null
          file_set_id?: string | null
          id?: string
          item_key: string
          kind: string
          message_id?: string | null
          revision_id?: string | null
          sha256?: string | null
          submission_id: string
          tenant_id: string
          workspace_id: string
        }
        Update: {
          artifact_id?: string | null
          availability?: string
          created_at?: string
          deployment_id?: string | null
          external_ref?: Json | null
          file_set_id?: string | null
          id?: string
          item_key?: string
          kind?: string
          message_id?: string | null
          revision_id?: string | null
          sha256?: string | null
          submission_id?: string
          tenant_id?: string
          workspace_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "evidence_item_tenant_id_workspace_id_submission_id_fkey"
            columns: ["tenant_id", "workspace_id", "submission_id"]
            isOneToOne: false
            referencedRelation: "submission"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
        ]
      }
      grading_run: {
        Row: {
          check_bundle_sha256: string | null
          created_at: string
          failure_class: string | null
          finished_at: string | null
          id: string
          kind: string
          pipeline_revision_id: string
          reason: string | null
          replay_artifact_id: string | null
          requested_by: string
          runner: Json
          runtime_ref: Json
          started_at: string | null
          status: string
          submission_id: string
          tenant_id: string
          workspace_id: string
        }
        Insert: {
          check_bundle_sha256?: string | null
          created_at?: string
          failure_class?: string | null
          finished_at?: string | null
          id?: string
          kind: string
          pipeline_revision_id: string
          reason?: string | null
          replay_artifact_id?: string | null
          requested_by: string
          runner?: Json
          runtime_ref?: Json
          started_at?: string | null
          status: string
          submission_id: string
          tenant_id: string
          workspace_id: string
        }
        Update: {
          check_bundle_sha256?: string | null
          created_at?: string
          failure_class?: string | null
          finished_at?: string | null
          id?: string
          kind?: string
          pipeline_revision_id?: string
          reason?: string | null
          replay_artifact_id?: string | null
          requested_by?: string
          runner?: Json
          runtime_ref?: Json
          started_at?: string | null
          status?: string
          submission_id?: string
          tenant_id?: string
          workspace_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "grading_run_tenant_id_workspace_id_submission_id_fkey"
            columns: ["tenant_id", "workspace_id", "submission_id"]
            isOneToOne: false
            referencedRelation: "submission"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
        ]
      }
      mastery_decision: {
        Row: {
          competency_revision_id: string
          created_at: string
          decided_by: string
          evidence: Json
          facet: string
          id: string
          learner_id: string
          policy_revision_id: string
          review_due_at: string | null
          state: string
          supersedes_id: string | null
          tenant_id: string
          uncertainty: string
          workspace_id: string
        }
        Insert: {
          competency_revision_id: string
          created_at?: string
          decided_by: string
          evidence?: Json
          facet: string
          id?: string
          learner_id: string
          policy_revision_id: string
          review_due_at?: string | null
          state: string
          supersedes_id?: string | null
          tenant_id: string
          uncertainty: string
          workspace_id: string
        }
        Update: {
          competency_revision_id?: string
          created_at?: string
          decided_by?: string
          evidence?: Json
          facet?: string
          id?: string
          learner_id?: string
          policy_revision_id?: string
          review_due_at?: string | null
          state?: string
          supersedes_id?: string | null
          tenant_id?: string
          uncertainty?: string
          workspace_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "mastery_decision_tenant_id_workspace_id_supersedes_id_fkey"
            columns: ["tenant_id", "workspace_id", "supersedes_id"]
            isOneToOne: false
            referencedRelation: "mastery_decision"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
        ]
      }
      release_adoption: {
        Row: {
          actor_id: string
          basis: string
          created_at: string
          enrollment_id: string
          id: string
          offer_id: string
          personal_revision_id: string | null
          previous_adoption_id: string | null
          reason: string
          sequence_no: number
          source_workspace_id: string
          tenant_id: string
          transition_id: string | null
          workspace_id: string
        }
        Insert: {
          actor_id: string
          basis: string
          created_at?: string
          enrollment_id: string
          id?: string
          offer_id: string
          personal_revision_id?: string | null
          previous_adoption_id?: string | null
          reason: string
          sequence_no: number
          source_workspace_id: string
          tenant_id: string
          transition_id?: string | null
          workspace_id: string
        }
        Update: {
          actor_id?: string
          basis?: string
          created_at?: string
          enrollment_id?: string
          id?: string
          offer_id?: string
          personal_revision_id?: string | null
          previous_adoption_id?: string | null
          reason?: string
          sequence_no?: number
          source_workspace_id?: string
          tenant_id?: string
          transition_id?: string | null
          workspace_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "release_adoption_tenant_id_workspace_id_enrollment_id_fkey"
            columns: ["tenant_id", "workspace_id", "enrollment_id"]
            isOneToOne: false
            referencedRelation: "enrollment"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
          {
            foreignKeyName: "release_adoption_tenant_id_workspace_id_enrollment_id_prev_fkey"
            columns: [
              "tenant_id",
              "workspace_id",
              "enrollment_id",
              "previous_adoption_id",
            ]
            isOneToOne: false
            referencedRelation: "release_adoption"
            referencedColumns: [
              "tenant_id",
              "workspace_id",
              "enrollment_id",
              "id",
            ]
          },
        ]
      }
      submission: {
        Row: {
          attempt_id: string
          closure_sha256: string
          created_at: string
          id: string
          learner_id: string
          manifest_artifact_id: string
          observed_conditions: Json
          submitted_via: string
          tenant_id: string
          withdrawn_at: string | null
          workspace_id: string
        }
        Insert: {
          attempt_id: string
          closure_sha256: string
          created_at?: string
          id?: string
          learner_id: string
          manifest_artifact_id: string
          observed_conditions?: Json
          submitted_via: string
          tenant_id: string
          withdrawn_at?: string | null
          workspace_id: string
        }
        Update: {
          attempt_id?: string
          closure_sha256?: string
          created_at?: string
          id?: string
          learner_id?: string
          manifest_artifact_id?: string
          observed_conditions?: Json
          submitted_via?: string
          tenant_id?: string
          withdrawn_at?: string | null
          workspace_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "submission_tenant_id_workspace_id_attempt_id_fkey"
            columns: ["tenant_id", "workspace_id", "attempt_id"]
            isOneToOne: true
            referencedRelation: "attempt"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  library: {
    Tables: {
      connected_item: {
        Row: {
          connection_id: string
          editing_home: string
          external_id: string
          external_kind: string
          external_location: string
          id: string
          remote_revision: string | null
          selected_via: string
          suppressed_at: string | null
          sync_state: string
          synced_revision_id: string | null
          tenant_id: string
          updated_at: string
          work_id: string
          workspace_id: string
        }
        Insert: {
          connection_id: string
          editing_home: string
          external_id: string
          external_kind: string
          external_location: string
          id?: string
          remote_revision?: string | null
          selected_via: string
          suppressed_at?: string | null
          sync_state: string
          synced_revision_id?: string | null
          tenant_id: string
          updated_at?: string
          work_id: string
          workspace_id: string
        }
        Update: {
          connection_id?: string
          editing_home?: string
          external_id?: string
          external_kind?: string
          external_location?: string
          id?: string
          remote_revision?: string | null
          selected_via?: string
          suppressed_at?: string | null
          sync_state?: string
          synced_revision_id?: string | null
          tenant_id?: string
          updated_at?: string
          work_id?: string
          workspace_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "connected_item_tenant_id_workspace_id_connection_id_fkey"
            columns: ["tenant_id", "workspace_id", "connection_id"]
            isOneToOne: false
            referencedRelation: "connection"
            referencedColumns: ["tenant_id", "workspace_id", "id"]
          },
        ]
      }
      connection: {
        Row: {
          account_label: string
          capabilities: string[]
          connected_by: string
          created_at: string
          credential_handle: string
          disconnected_at: string | null
          id: string
          last_error: string | null
          provider: string
          status: string
          tenant_id: string
          workspace_id: string
        }
        Insert: {
          account_label: string
          capabilities: string[]
          connected_by: string
          created_at?: string
          credential_handle: string
          disconnected_at?: string | null
          id?: string
          last_error?: string | null
          provider: string
          status: string
          tenant_id: string
          workspace_id: string
        }
        Update: {
          account_label?: string
          capabilities?: string[]
          connected_by?: string
          created_at?: string
          credential_handle?: string
          disconnected_at?: string | null
          id?: string
          last_error?: string | null
          provider?: string
          status?: string
          tenant_id?: string
          workspace_id?: string
        }
        Relationships: []
      }
      passage: {
        Row: {
          artifact_id: string | null
          content_sha256: string
          created_at: string
          id: string
          language: unknown
          locator: Json
          message_id: string | null
          passage_no: number
          procedure_version: string
          revision_id: string | null
          tenant_id: string
          text: string
          tsv: unknown
          workspace_id: string
        }
        Insert: {
          artifact_id?: string | null
          content_sha256: string
          created_at?: string
          id?: string
          language?: unknown
          locator: Json
          message_id?: string | null
          passage_no: number
          procedure_version: string
          revision_id?: string | null
          tenant_id: string
          text: string
          tsv?: unknown
          workspace_id: string
        }
        Update: {
          artifact_id?: string | null
          content_sha256?: string
          created_at?: string
          id?: string
          language?: unknown
          locator?: Json
          message_id?: string | null
          passage_no?: number
          procedure_version?: string
          revision_id?: string | null
          tenant_id?: string
          text?: string
          tsv?: unknown
          workspace_id?: string
        }
        Relationships: []
      }
      preparation: {
        Row: {
          artifact_id: string | null
          attempt_count: number
          failure_class: string | null
          id: string
          origin_ref: Json
          output_ref: Json
          procedure_version: string
          revision_id: string | null
          stage: string
          status: string
          tenant_id: string
          updated_at: string
          workspace_id: string
        }
        Insert: {
          artifact_id?: string | null
          attempt_count?: number
          failure_class?: string | null
          id?: string
          origin_ref?: Json
          output_ref?: Json
          procedure_version: string
          revision_id?: string | null
          stage: string
          status: string
          tenant_id: string
          updated_at?: string
          workspace_id: string
        }
        Update: {
          artifact_id?: string | null
          attempt_count?: number
          failure_class?: string | null
          id?: string
          origin_ref?: Json
          output_ref?: Json
          procedure_version?: string
          revision_id?: string | null
          stage?: string
          status?: string
          tenant_id?: string
          updated_at?: string
          workspace_id?: string
        }
        Relationships: []
      }
      removal: {
        Row: {
          completed_at: string | null
          created_at: string
          id: string
          impact: Json
          impact_acknowledged_event_id: string | null
          requested_by: string
          state: string
          steps: Json
          targets: Json
          tenant_id: string
          workspace_id: string
        }
        Insert: {
          completed_at?: string | null
          created_at?: string
          id?: string
          impact: Json
          impact_acknowledged_event_id?: string | null
          requested_by: string
          state: string
          steps?: Json
          targets: Json
          tenant_id: string
          workspace_id: string
        }
        Update: {
          completed_at?: string | null
          created_at?: string
          id?: string
          impact?: Json
          impact_acknowledged_event_id?: string | null
          requested_by?: string
          state?: string
          steps?: Json
          targets?: Json
          tenant_id?: string
          workspace_id?: string
        }
        Relationships: []
      }
      resource_control: {
        Row: {
          excluded_at: string | null
          excluded_by: string | null
          semantic_index: boolean
          tenant_id: string
          updated_at: string
          updated_by: string
          work_id: string
          workspace_id: string
        }
        Insert: {
          excluded_at?: string | null
          excluded_by?: string | null
          semantic_index?: boolean
          tenant_id: string
          updated_at?: string
          updated_by: string
          work_id: string
          workspace_id: string
        }
        Update: {
          excluded_at?: string | null
          excluded_by?: string | null
          semantic_index?: boolean
          tenant_id?: string
          updated_at?: string
          updated_by?: string
          work_id?: string
          workspace_id?: string
        }
        Relationships: []
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  observability: {
    Tables: {
      coordinator_handoff: {
        Row: {
          checkpoint_id: string | null
          created_at: string
          id: string
          new_session_id: string | null
          old_session_id: string | null
          verification_state: string
        }
        Insert: {
          checkpoint_id?: string | null
          created_at?: string
          id?: string
          new_session_id?: string | null
          old_session_id?: string | null
          verification_state?: string
        }
        Update: {
          checkpoint_id?: string | null
          created_at?: string
          id?: string
          new_session_id?: string | null
          old_session_id?: string | null
          verification_state?: string
        }
        Relationships: []
      }
      io_link: {
        Row: {
          artifact_id: string
          created_at: string
          direction: string
          encrypted: boolean
          id: string
          span_id: string | null
          trace_id: string | null
        }
        Insert: {
          artifact_id: string
          created_at?: string
          direction: string
          encrypted?: boolean
          id?: string
          span_id?: string | null
          trace_id?: string | null
        }
        Update: {
          artifact_id?: string
          created_at?: string
          direction?: string
          encrypted?: boolean
          id?: string
          span_id?: string | null
          trace_id?: string | null
        }
        Relationships: []
      }
      normalized_event: {
        Row: {
          event_kind: string
          id: string
          lifecycle_phase: string | null
          mission_id: string | null
          occurred_at: string
          payload: Json
          raw_event_id: string | null
          trace_id: string | null
        }
        Insert: {
          event_kind: string
          id?: string
          lifecycle_phase?: string | null
          mission_id?: string | null
          occurred_at?: string
          payload?: Json
          raw_event_id?: string | null
          trace_id?: string | null
        }
        Update: {
          event_kind?: string
          id?: string
          lifecycle_phase?: string | null
          mission_id?: string | null
          occurred_at?: string
          payload?: Json
          raw_event_id?: string | null
          trace_id?: string | null
        }
        Relationships: []
      }
      normalized_event_202610: {
        Row: {
          event_kind: string
          id: string
          lifecycle_phase: string | null
          mission_id: string | null
          occurred_at: string
          payload: Json
          raw_event_id: string | null
          trace_id: string | null
        }
        Insert: {
          event_kind: string
          id?: string
          lifecycle_phase?: string | null
          mission_id?: string | null
          occurred_at?: string
          payload?: Json
          raw_event_id?: string | null
          trace_id?: string | null
        }
        Update: {
          event_kind?: string
          id?: string
          lifecycle_phase?: string | null
          mission_id?: string | null
          occurred_at?: string
          payload?: Json
          raw_event_id?: string | null
          trace_id?: string | null
        }
        Relationships: []
      }
      normalized_event_202611: {
        Row: {
          event_kind: string
          id: string
          lifecycle_phase: string | null
          mission_id: string | null
          occurred_at: string
          payload: Json
          raw_event_id: string | null
          trace_id: string | null
        }
        Insert: {
          event_kind: string
          id?: string
          lifecycle_phase?: string | null
          mission_id?: string | null
          occurred_at?: string
          payload?: Json
          raw_event_id?: string | null
          trace_id?: string | null
        }
        Update: {
          event_kind?: string
          id?: string
          lifecycle_phase?: string | null
          mission_id?: string | null
          occurred_at?: string
          payload?: Json
          raw_event_id?: string | null
          trace_id?: string | null
        }
        Relationships: []
      }
      normalized_event_202612: {
        Row: {
          event_kind: string
          id: string
          lifecycle_phase: string | null
          mission_id: string | null
          occurred_at: string
          payload: Json
          raw_event_id: string | null
          trace_id: string | null
        }
        Insert: {
          event_kind: string
          id?: string
          lifecycle_phase?: string | null
          mission_id?: string | null
          occurred_at?: string
          payload?: Json
          raw_event_id?: string | null
          trace_id?: string | null
        }
        Update: {
          event_kind?: string
          id?: string
          lifecycle_phase?: string | null
          mission_id?: string | null
          occurred_at?: string
          payload?: Json
          raw_event_id?: string | null
          trace_id?: string | null
        }
        Relationships: []
      }
      normalized_event_202701: {
        Row: {
          event_kind: string
          id: string
          lifecycle_phase: string | null
          mission_id: string | null
          occurred_at: string
          payload: Json
          raw_event_id: string | null
          trace_id: string | null
        }
        Insert: {
          event_kind: string
          id?: string
          lifecycle_phase?: string | null
          mission_id?: string | null
          occurred_at?: string
          payload?: Json
          raw_event_id?: string | null
          trace_id?: string | null
        }
        Update: {
          event_kind?: string
          id?: string
          lifecycle_phase?: string | null
          mission_id?: string | null
          occurred_at?: string
          payload?: Json
          raw_event_id?: string | null
          trace_id?: string | null
        }
        Relationships: []
      }
      normalized_event_202702: {
        Row: {
          event_kind: string
          id: string
          lifecycle_phase: string | null
          mission_id: string | null
          occurred_at: string
          payload: Json
          raw_event_id: string | null
          trace_id: string | null
        }
        Insert: {
          event_kind: string
          id?: string
          lifecycle_phase?: string | null
          mission_id?: string | null
          occurred_at?: string
          payload?: Json
          raw_event_id?: string | null
          trace_id?: string | null
        }
        Update: {
          event_kind?: string
          id?: string
          lifecycle_phase?: string | null
          mission_id?: string | null
          occurred_at?: string
          payload?: Json
          raw_event_id?: string | null
          trace_id?: string | null
        }
        Relationships: []
      }
      normalized_event_202703: {
        Row: {
          event_kind: string
          id: string
          lifecycle_phase: string | null
          mission_id: string | null
          occurred_at: string
          payload: Json
          raw_event_id: string | null
          trace_id: string | null
        }
        Insert: {
          event_kind: string
          id?: string
          lifecycle_phase?: string | null
          mission_id?: string | null
          occurred_at?: string
          payload?: Json
          raw_event_id?: string | null
          trace_id?: string | null
        }
        Update: {
          event_kind?: string
          id?: string
          lifecycle_phase?: string | null
          mission_id?: string | null
          occurred_at?: string
          payload?: Json
          raw_event_id?: string | null
          trace_id?: string | null
        }
        Relationships: []
      }
      normalized_event_202704: {
        Row: {
          event_kind: string
          id: string
          lifecycle_phase: string | null
          mission_id: string | null
          occurred_at: string
          payload: Json
          raw_event_id: string | null
          trace_id: string | null
        }
        Insert: {
          event_kind: string
          id?: string
          lifecycle_phase?: string | null
          mission_id?: string | null
          occurred_at?: string
          payload?: Json
          raw_event_id?: string | null
          trace_id?: string | null
        }
        Update: {
          event_kind?: string
          id?: string
          lifecycle_phase?: string | null
          mission_id?: string | null
          occurred_at?: string
          payload?: Json
          raw_event_id?: string | null
          trace_id?: string | null
        }
        Relationships: []
      }
      normalized_event_202705: {
        Row: {
          event_kind: string
          id: string
          lifecycle_phase: string | null
          mission_id: string | null
          occurred_at: string
          payload: Json
          raw_event_id: string | null
          trace_id: string | null
        }
        Insert: {
          event_kind: string
          id?: string
          lifecycle_phase?: string | null
          mission_id?: string | null
          occurred_at?: string
          payload?: Json
          raw_event_id?: string | null
          trace_id?: string | null
        }
        Update: {
          event_kind?: string
          id?: string
          lifecycle_phase?: string | null
          mission_id?: string | null
          occurred_at?: string
          payload?: Json
          raw_event_id?: string | null
          trace_id?: string | null
        }
        Relationships: []
      }
      raw_event: {
        Row: {
          event: Json
          id: string
          idempotency_key: string
          occurred_at: string
          stream_cursor: string | null
          trace_id: string | null
        }
        Insert: {
          event: Json
          id?: string
          idempotency_key: string
          occurred_at?: string
          stream_cursor?: string | null
          trace_id?: string | null
        }
        Update: {
          event?: Json
          id?: string
          idempotency_key?: string
          occurred_at?: string
          stream_cursor?: string | null
          trace_id?: string | null
        }
        Relationships: []
      }
      raw_event_202610: {
        Row: {
          event: Json
          id: string
          idempotency_key: string
          occurred_at: string
          stream_cursor: string | null
          trace_id: string | null
        }
        Insert: {
          event: Json
          id?: string
          idempotency_key: string
          occurred_at?: string
          stream_cursor?: string | null
          trace_id?: string | null
        }
        Update: {
          event?: Json
          id?: string
          idempotency_key?: string
          occurred_at?: string
          stream_cursor?: string | null
          trace_id?: string | null
        }
        Relationships: []
      }
      raw_event_202611: {
        Row: {
          event: Json
          id: string
          idempotency_key: string
          occurred_at: string
          stream_cursor: string | null
          trace_id: string | null
        }
        Insert: {
          event: Json
          id?: string
          idempotency_key: string
          occurred_at?: string
          stream_cursor?: string | null
          trace_id?: string | null
        }
        Update: {
          event?: Json
          id?: string
          idempotency_key?: string
          occurred_at?: string
          stream_cursor?: string | null
          trace_id?: string | null
        }
        Relationships: []
      }
      raw_event_202612: {
        Row: {
          event: Json
          id: string
          idempotency_key: string
          occurred_at: string
          stream_cursor: string | null
          trace_id: string | null
        }
        Insert: {
          event: Json
          id?: string
          idempotency_key: string
          occurred_at?: string
          stream_cursor?: string | null
          trace_id?: string | null
        }
        Update: {
          event?: Json
          id?: string
          idempotency_key?: string
          occurred_at?: string
          stream_cursor?: string | null
          trace_id?: string | null
        }
        Relationships: []
      }
      raw_event_202701: {
        Row: {
          event: Json
          id: string
          idempotency_key: string
          occurred_at: string
          stream_cursor: string | null
          trace_id: string | null
        }
        Insert: {
          event: Json
          id?: string
          idempotency_key: string
          occurred_at?: string
          stream_cursor?: string | null
          trace_id?: string | null
        }
        Update: {
          event?: Json
          id?: string
          idempotency_key?: string
          occurred_at?: string
          stream_cursor?: string | null
          trace_id?: string | null
        }
        Relationships: []
      }
      raw_event_202702: {
        Row: {
          event: Json
          id: string
          idempotency_key: string
          occurred_at: string
          stream_cursor: string | null
          trace_id: string | null
        }
        Insert: {
          event: Json
          id?: string
          idempotency_key: string
          occurred_at?: string
          stream_cursor?: string | null
          trace_id?: string | null
        }
        Update: {
          event?: Json
          id?: string
          idempotency_key?: string
          occurred_at?: string
          stream_cursor?: string | null
          trace_id?: string | null
        }
        Relationships: []
      }
      raw_event_202703: {
        Row: {
          event: Json
          id: string
          idempotency_key: string
          occurred_at: string
          stream_cursor: string | null
          trace_id: string | null
        }
        Insert: {
          event: Json
          id?: string
          idempotency_key: string
          occurred_at?: string
          stream_cursor?: string | null
          trace_id?: string | null
        }
        Update: {
          event?: Json
          id?: string
          idempotency_key?: string
          occurred_at?: string
          stream_cursor?: string | null
          trace_id?: string | null
        }
        Relationships: []
      }
      raw_event_202704: {
        Row: {
          event: Json
          id: string
          idempotency_key: string
          occurred_at: string
          stream_cursor: string | null
          trace_id: string | null
        }
        Insert: {
          event: Json
          id?: string
          idempotency_key: string
          occurred_at?: string
          stream_cursor?: string | null
          trace_id?: string | null
        }
        Update: {
          event?: Json
          id?: string
          idempotency_key?: string
          occurred_at?: string
          stream_cursor?: string | null
          trace_id?: string | null
        }
        Relationships: []
      }
      raw_event_202705: {
        Row: {
          event: Json
          id: string
          idempotency_key: string
          occurred_at: string
          stream_cursor: string | null
          trace_id: string | null
        }
        Insert: {
          event: Json
          id?: string
          idempotency_key: string
          occurred_at?: string
          stream_cursor?: string | null
          trace_id?: string | null
        }
        Update: {
          event?: Json
          id?: string
          idempotency_key?: string
          occurred_at?: string
          stream_cursor?: string | null
          trace_id?: string | null
        }
        Relationships: []
      }
      span: {
        Row: {
          attributes: Json
          cost_usd: number | null
          duration_ms: number | null
          ended_at: string | null
          id: string
          kind: string
          name: string
          occurred_at: string
          parent_span_id: string | null
          span_id: string
          started_at: string
          status: string
          token_input: number | null
          token_output: number | null
          trace_id: string
        }
        Insert: {
          attributes?: Json
          cost_usd?: number | null
          duration_ms?: number | null
          ended_at?: string | null
          id?: string
          kind: string
          name: string
          occurred_at?: string
          parent_span_id?: string | null
          span_id: string
          started_at: string
          status?: string
          token_input?: number | null
          token_output?: number | null
          trace_id: string
        }
        Update: {
          attributes?: Json
          cost_usd?: number | null
          duration_ms?: number | null
          ended_at?: string | null
          id?: string
          kind?: string
          name?: string
          occurred_at?: string
          parent_span_id?: string | null
          span_id?: string
          started_at?: string
          status?: string
          token_input?: number | null
          token_output?: number | null
          trace_id?: string
        }
        Relationships: []
      }
      span_202610: {
        Row: {
          attributes: Json
          cost_usd: number | null
          duration_ms: number | null
          ended_at: string | null
          id: string
          kind: string
          name: string
          occurred_at: string
          parent_span_id: string | null
          span_id: string
          started_at: string
          status: string
          token_input: number | null
          token_output: number | null
          trace_id: string
        }
        Insert: {
          attributes?: Json
          cost_usd?: number | null
          duration_ms?: number | null
          ended_at?: string | null
          id?: string
          kind: string
          name: string
          occurred_at?: string
          parent_span_id?: string | null
          span_id: string
          started_at: string
          status?: string
          token_input?: number | null
          token_output?: number | null
          trace_id: string
        }
        Update: {
          attributes?: Json
          cost_usd?: number | null
          duration_ms?: number | null
          ended_at?: string | null
          id?: string
          kind?: string
          name?: string
          occurred_at?: string
          parent_span_id?: string | null
          span_id?: string
          started_at?: string
          status?: string
          token_input?: number | null
          token_output?: number | null
          trace_id?: string
        }
        Relationships: []
      }
      span_202611: {
        Row: {
          attributes: Json
          cost_usd: number | null
          duration_ms: number | null
          ended_at: string | null
          id: string
          kind: string
          name: string
          occurred_at: string
          parent_span_id: string | null
          span_id: string
          started_at: string
          status: string
          token_input: number | null
          token_output: number | null
          trace_id: string
        }
        Insert: {
          attributes?: Json
          cost_usd?: number | null
          duration_ms?: number | null
          ended_at?: string | null
          id?: string
          kind: string
          name: string
          occurred_at?: string
          parent_span_id?: string | null
          span_id: string
          started_at: string
          status?: string
          token_input?: number | null
          token_output?: number | null
          trace_id: string
        }
        Update: {
          attributes?: Json
          cost_usd?: number | null
          duration_ms?: number | null
          ended_at?: string | null
          id?: string
          kind?: string
          name?: string
          occurred_at?: string
          parent_span_id?: string | null
          span_id?: string
          started_at?: string
          status?: string
          token_input?: number | null
          token_output?: number | null
          trace_id?: string
        }
        Relationships: []
      }
      span_202612: {
        Row: {
          attributes: Json
          cost_usd: number | null
          duration_ms: number | null
          ended_at: string | null
          id: string
          kind: string
          name: string
          occurred_at: string
          parent_span_id: string | null
          span_id: string
          started_at: string
          status: string
          token_input: number | null
          token_output: number | null
          trace_id: string
        }
        Insert: {
          attributes?: Json
          cost_usd?: number | null
          duration_ms?: number | null
          ended_at?: string | null
          id?: string
          kind: string
          name: string
          occurred_at?: string
          parent_span_id?: string | null
          span_id: string
          started_at: string
          status?: string
          token_input?: number | null
          token_output?: number | null
          trace_id: string
        }
        Update: {
          attributes?: Json
          cost_usd?: number | null
          duration_ms?: number | null
          ended_at?: string | null
          id?: string
          kind?: string
          name?: string
          occurred_at?: string
          parent_span_id?: string | null
          span_id?: string
          started_at?: string
          status?: string
          token_input?: number | null
          token_output?: number | null
          trace_id?: string
        }
        Relationships: []
      }
      span_202701: {
        Row: {
          attributes: Json
          cost_usd: number | null
          duration_ms: number | null
          ended_at: string | null
          id: string
          kind: string
          name: string
          occurred_at: string
          parent_span_id: string | null
          span_id: string
          started_at: string
          status: string
          token_input: number | null
          token_output: number | null
          trace_id: string
        }
        Insert: {
          attributes?: Json
          cost_usd?: number | null
          duration_ms?: number | null
          ended_at?: string | null
          id?: string
          kind: string
          name: string
          occurred_at?: string
          parent_span_id?: string | null
          span_id: string
          started_at: string
          status?: string
          token_input?: number | null
          token_output?: number | null
          trace_id: string
        }
        Update: {
          attributes?: Json
          cost_usd?: number | null
          duration_ms?: number | null
          ended_at?: string | null
          id?: string
          kind?: string
          name?: string
          occurred_at?: string
          parent_span_id?: string | null
          span_id?: string
          started_at?: string
          status?: string
          token_input?: number | null
          token_output?: number | null
          trace_id?: string
        }
        Relationships: []
      }
      span_202702: {
        Row: {
          attributes: Json
          cost_usd: number | null
          duration_ms: number | null
          ended_at: string | null
          id: string
          kind: string
          name: string
          occurred_at: string
          parent_span_id: string | null
          span_id: string
          started_at: string
          status: string
          token_input: number | null
          token_output: number | null
          trace_id: string
        }
        Insert: {
          attributes?: Json
          cost_usd?: number | null
          duration_ms?: number | null
          ended_at?: string | null
          id?: string
          kind: string
          name: string
          occurred_at?: string
          parent_span_id?: string | null
          span_id: string
          started_at: string
          status?: string
          token_input?: number | null
          token_output?: number | null
          trace_id: string
        }
        Update: {
          attributes?: Json
          cost_usd?: number | null
          duration_ms?: number | null
          ended_at?: string | null
          id?: string
          kind?: string
          name?: string
          occurred_at?: string
          parent_span_id?: string | null
          span_id?: string
          started_at?: string
          status?: string
          token_input?: number | null
          token_output?: number | null
          trace_id?: string
        }
        Relationships: []
      }
      span_202703: {
        Row: {
          attributes: Json
          cost_usd: number | null
          duration_ms: number | null
          ended_at: string | null
          id: string
          kind: string
          name: string
          occurred_at: string
          parent_span_id: string | null
          span_id: string
          started_at: string
          status: string
          token_input: number | null
          token_output: number | null
          trace_id: string
        }
        Insert: {
          attributes?: Json
          cost_usd?: number | null
          duration_ms?: number | null
          ended_at?: string | null
          id?: string
          kind: string
          name: string
          occurred_at?: string
          parent_span_id?: string | null
          span_id: string
          started_at: string
          status?: string
          token_input?: number | null
          token_output?: number | null
          trace_id: string
        }
        Update: {
          attributes?: Json
          cost_usd?: number | null
          duration_ms?: number | null
          ended_at?: string | null
          id?: string
          kind?: string
          name?: string
          occurred_at?: string
          parent_span_id?: string | null
          span_id?: string
          started_at?: string
          status?: string
          token_input?: number | null
          token_output?: number | null
          trace_id?: string
        }
        Relationships: []
      }
      span_202704: {
        Row: {
          attributes: Json
          cost_usd: number | null
          duration_ms: number | null
          ended_at: string | null
          id: string
          kind: string
          name: string
          occurred_at: string
          parent_span_id: string | null
          span_id: string
          started_at: string
          status: string
          token_input: number | null
          token_output: number | null
          trace_id: string
        }
        Insert: {
          attributes?: Json
          cost_usd?: number | null
          duration_ms?: number | null
          ended_at?: string | null
          id?: string
          kind: string
          name: string
          occurred_at?: string
          parent_span_id?: string | null
          span_id: string
          started_at: string
          status?: string
          token_input?: number | null
          token_output?: number | null
          trace_id: string
        }
        Update: {
          attributes?: Json
          cost_usd?: number | null
          duration_ms?: number | null
          ended_at?: string | null
          id?: string
          kind?: string
          name?: string
          occurred_at?: string
          parent_span_id?: string | null
          span_id?: string
          started_at?: string
          status?: string
          token_input?: number | null
          token_output?: number | null
          trace_id?: string
        }
        Relationships: []
      }
      span_202705: {
        Row: {
          attributes: Json
          cost_usd: number | null
          duration_ms: number | null
          ended_at: string | null
          id: string
          kind: string
          name: string
          occurred_at: string
          parent_span_id: string | null
          span_id: string
          started_at: string
          status: string
          token_input: number | null
          token_output: number | null
          trace_id: string
        }
        Insert: {
          attributes?: Json
          cost_usd?: number | null
          duration_ms?: number | null
          ended_at?: string | null
          id?: string
          kind: string
          name: string
          occurred_at?: string
          parent_span_id?: string | null
          span_id: string
          started_at: string
          status?: string
          token_input?: number | null
          token_output?: number | null
          trace_id: string
        }
        Update: {
          attributes?: Json
          cost_usd?: number | null
          duration_ms?: number | null
          ended_at?: string | null
          id?: string
          kind?: string
          name?: string
          occurred_at?: string
          parent_span_id?: string | null
          span_id?: string
          started_at?: string
          status?: string
          token_input?: number | null
          token_output?: number | null
          trace_id?: string
        }
        Relationships: []
      }
      trace: {
        Row: {
          attempt_id: string | null
          causation_id: string | null
          ended_at: string | null
          mission_id: string | null
          root_span_id: string | null
          started_at: string
          tenant_id: string
          trace_id: string
          work_item_id: string | null
        }
        Insert: {
          attempt_id?: string | null
          causation_id?: string | null
          ended_at?: string | null
          mission_id?: string | null
          root_span_id?: string | null
          started_at?: string
          tenant_id?: string
          trace_id: string
          work_item_id?: string | null
        }
        Update: {
          attempt_id?: string | null
          causation_id?: string | null
          ended_at?: string | null
          mission_id?: string | null
          root_span_id?: string | null
          started_at?: string
          tenant_id?: string
          trace_id?: string
          work_item_id?: string | null
        }
        Relationships: []
      }
      usage_rollup: {
        Row: {
          computed_at: string
          cost_usd: number
          day: string
          id: string
          latency_ms_p50: number | null
          latency_ms_p95: number | null
          mission_id: string | null
          retry_count: number
          span_count: number
          token_input: number
          token_output: number
        }
        Insert: {
          computed_at?: string
          cost_usd?: number
          day: string
          id?: string
          latency_ms_p50?: number | null
          latency_ms_p95?: number | null
          mission_id?: string | null
          retry_count?: number
          span_count?: number
          token_input?: number
          token_output?: number
        }
        Update: {
          computed_at?: string
          cost_usd?: number
          day?: string
          id?: string
          latency_ms_p50?: number | null
          latency_ms_p95?: number | null
          mission_id?: string | null
          retry_count?: number
          span_count?: number
          token_input?: number
          token_output?: number
        }
        Relationships: []
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  orchestration: {
    Tables: {
      agent_session: {
        Row: {
          agent_deployment: string
          compaction_count: number
          ended_at: string | null
          eve_session_id: string
          id: string
          mission_id: string | null
          rotated_from_id: string | null
          started_at: string
          status: string
          tenant_id: string
        }
        Insert: {
          agent_deployment: string
          compaction_count?: number
          ended_at?: string | null
          eve_session_id: string
          id?: string
          mission_id?: string | null
          rotated_from_id?: string | null
          started_at?: string
          status?: string
          tenant_id?: string
        }
        Update: {
          agent_deployment?: string
          compaction_count?: number
          ended_at?: string | null
          eve_session_id?: string
          id?: string
          mission_id?: string | null
          rotated_from_id?: string | null
          started_at?: string
          status?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "agent_session_mission_id_fkey"
            columns: ["mission_id"]
            isOneToOne: false
            referencedRelation: "mission"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "agent_session_rotated_from_id_fkey"
            columns: ["rotated_from_id"]
            isOneToOne: false
            referencedRelation: "agent_session"
            referencedColumns: ["id"]
          },
        ]
      }
      artifact: {
        Row: {
          artifact_type: string
          available_at: string | null
          bucket_class: Database["orchestration"]["Enums"]["bucket_class"]
          created_at: string
          custody_registered_at: string
          id: string
          media_type: string | null
          mission_id: string | null
          object_path: string
          producer_attempt_id: string | null
          registration_error_class: string | null
          schema_version: number
          sha256: string
          size_bytes: number | null
          storage_bucket: string
          storage_state: string
          superseded_by_id: string | null
          tenant_id: string
          verification_contract_version: string | null
        }
        Insert: {
          artifact_type: string
          available_at?: string | null
          bucket_class: Database["orchestration"]["Enums"]["bucket_class"]
          created_at?: string
          custody_registered_at?: string
          id?: string
          media_type?: string | null
          mission_id?: string | null
          object_path: string
          producer_attempt_id?: string | null
          registration_error_class?: string | null
          schema_version?: number
          sha256: string
          size_bytes?: number | null
          storage_bucket: string
          storage_state?: string
          superseded_by_id?: string | null
          tenant_id?: string
          verification_contract_version?: string | null
        }
        Update: {
          artifact_type?: string
          available_at?: string | null
          bucket_class?: Database["orchestration"]["Enums"]["bucket_class"]
          created_at?: string
          custody_registered_at?: string
          id?: string
          media_type?: string | null
          mission_id?: string | null
          object_path?: string
          producer_attempt_id?: string | null
          registration_error_class?: string | null
          schema_version?: number
          sha256?: string
          size_bytes?: number | null
          storage_bucket?: string
          storage_state?: string
          superseded_by_id?: string | null
          tenant_id?: string
          verification_contract_version?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "artifact_artifact_type_fkey"
            columns: ["artifact_type"]
            isOneToOne: false
            referencedRelation: "artifact_type"
            referencedColumns: ["code"]
          },
          {
            foreignKeyName: "artifact_mission_id_fkey"
            columns: ["mission_id"]
            isOneToOne: false
            referencedRelation: "mission"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "artifact_producer_attempt_id_fkey"
            columns: ["producer_attempt_id"]
            isOneToOne: false
            referencedRelation: "attempt"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "artifact_superseded_by_id_fkey"
            columns: ["superseded_by_id"]
            isOneToOne: false
            referencedRelation: "artifact"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "artifact_tenant_successor_fk"
            columns: ["tenant_id", "superseded_by_id"]
            isOneToOne: false
            referencedRelation: "artifact"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      artifact_lineage: {
        Row: {
          activity_id: string | null
          activity_version: string | null
          created_at: string
          from_artifact_id: string
          id: string
          receipt_id: string | null
          relation_kind: string
          tenant_id: string
          to_artifact_id: string
          transformation_run_id: string | null
          transformation_signature: string | null
        }
        Insert: {
          activity_id?: string | null
          activity_version?: string | null
          created_at?: string
          from_artifact_id: string
          id?: string
          receipt_id?: string | null
          relation_kind: string
          tenant_id?: string
          to_artifact_id: string
          transformation_run_id?: string | null
          transformation_signature?: string | null
        }
        Update: {
          activity_id?: string | null
          activity_version?: string | null
          created_at?: string
          from_artifact_id?: string
          id?: string
          receipt_id?: string | null
          relation_kind?: string
          tenant_id?: string
          to_artifact_id?: string
          transformation_run_id?: string | null
          transformation_signature?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "artifact_lineage_receipt_id_fkey"
            columns: ["receipt_id"]
            isOneToOne: false
            referencedRelation: "mission_run_effects"
            referencedColumns: ["receipt_id"]
          },
          {
            foreignKeyName: "artifact_lineage_receipt_id_fkey"
            columns: ["receipt_id"]
            isOneToOne: false
            referencedRelation: "operation_receipt"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "artifact_lineage_tenant_id_from_artifact_id_fkey"
            columns: ["tenant_id", "from_artifact_id"]
            isOneToOne: false
            referencedRelation: "artifact"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "artifact_lineage_tenant_id_to_artifact_id_fkey"
            columns: ["tenant_id", "to_artifact_id"]
            isOneToOne: false
            referencedRelation: "artifact"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      artifact_manifest: {
        Row: {
          created_at: string
          deferred: Json
          failed: Json
          id: string
          mission_id: string | null
          omitted: Json
          produced: Json
          required: Json
          work_item_id: string | null
        }
        Insert: {
          created_at?: string
          deferred?: Json
          failed?: Json
          id?: string
          mission_id?: string | null
          omitted?: Json
          produced?: Json
          required?: Json
          work_item_id?: string | null
        }
        Update: {
          created_at?: string
          deferred?: Json
          failed?: Json
          id?: string
          mission_id?: string | null
          omitted?: Json
          produced?: Json
          required?: Json
          work_item_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "artifact_manifest_mission_id_fkey"
            columns: ["mission_id"]
            isOneToOne: false
            referencedRelation: "mission"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "artifact_manifest_work_item_id_fkey"
            columns: ["work_item_id"]
            isOneToOne: false
            referencedRelation: "work_item"
            referencedColumns: ["id"]
          },
        ]
      }
      artifact_tombstone: {
        Row: {
          artifact_id: string
          reason: string
          retired_at: string
          tenant_id: string
        }
        Insert: {
          artifact_id: string
          reason: string
          retired_at?: string
          tenant_id: string
        }
        Update: {
          artifact_id?: string
          reason?: string
          retired_at?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "artifact_tombstone_tenant_id_artifact_id_fkey"
            columns: ["tenant_id", "artifact_id"]
            isOneToOne: true
            referencedRelation: "artifact"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      artifact_type: {
        Row: {
          code: string
          created_at: string
          description: string
        }
        Insert: {
          code: string
          created_at?: string
          description: string
        }
        Update: {
          code?: string
          created_at?: string
          description?: string
        }
        Relationships: []
      }
      attempt: {
        Row: {
          agent_deployment_id: string
          agent_session_id: string | null
          attempt_no: number
          cost_usd: number | null
          ended_at: string | null
          eve_turn_ids: string[]
          id: string
          latency_ms: number | null
          outcome: Database["orchestration"]["Enums"]["attempt_outcome"] | null
          remote_child_ids: string[]
          started_at: string
          tenant_id: string
          token_input: number | null
          token_output: number | null
          work_item_id: string
        }
        Insert: {
          agent_deployment_id: string
          agent_session_id?: string | null
          attempt_no: number
          cost_usd?: number | null
          ended_at?: string | null
          eve_turn_ids?: string[]
          id?: string
          latency_ms?: number | null
          outcome?: Database["orchestration"]["Enums"]["attempt_outcome"] | null
          remote_child_ids?: string[]
          started_at?: string
          tenant_id?: string
          token_input?: number | null
          token_output?: number | null
          work_item_id: string
        }
        Update: {
          agent_deployment_id?: string
          agent_session_id?: string | null
          attempt_no?: number
          cost_usd?: number | null
          ended_at?: string | null
          eve_turn_ids?: string[]
          id?: string
          latency_ms?: number | null
          outcome?: Database["orchestration"]["Enums"]["attempt_outcome"] | null
          remote_child_ids?: string[]
          started_at?: string
          tenant_id?: string
          token_input?: number | null
          token_output?: number | null
          work_item_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "attempt_agent_session_id_fkey"
            columns: ["agent_session_id"]
            isOneToOne: false
            referencedRelation: "agent_session"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "attempt_work_item_id_fkey"
            columns: ["work_item_id"]
            isOneToOne: false
            referencedRelation: "work_item"
            referencedColumns: ["id"]
          },
        ]
      }
      capability: {
        Row: {
          created_at: string
          id: string
          kind: string
          operations: string[]
          packages_mcp_server_version_id: string | null
          purpose: string
          slug: string
          tenant_id: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          id?: string
          kind: string
          operations?: string[]
          packages_mcp_server_version_id?: string | null
          purpose: string
          slug: string
          tenant_id?: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          id?: string
          kind?: string
          operations?: string[]
          packages_mcp_server_version_id?: string | null
          purpose?: string
          slug?: string
          tenant_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "capability_kind_fkey"
            columns: ["kind"]
            isOneToOne: false
            referencedRelation: "capability_kind"
            referencedColumns: ["code"]
          },
        ]
      }
      capability_kind: {
        Row: {
          code: string
          created_at: string
          description: string
        }
        Insert: {
          code: string
          created_at?: string
          description: string
        }
        Update: {
          code?: string
          created_at?: string
          description?: string
        }
        Relationships: []
      }
      capability_profile: {
        Row: {
          created_at: string
          id: string
          purpose: string
          slug: string
          tenant_id: string
        }
        Insert: {
          created_at?: string
          id?: string
          purpose: string
          slug: string
          tenant_id?: string
        }
        Update: {
          created_at?: string
          id?: string
          purpose?: string
          slug?: string
          tenant_id?: string
        }
        Relationships: []
      }
      capability_profile_item: {
        Row: {
          activation: string
          capability_version_id: string
          profile_id: string
        }
        Insert: {
          activation?: string
          capability_version_id: string
          profile_id: string
        }
        Update: {
          activation?: string
          capability_version_id?: string
          profile_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "capability_profile_item_capability_version_id_fkey"
            columns: ["capability_version_id"]
            isOneToOne: false
            referencedRelation: "capability_version"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "capability_profile_item_profile_id_fkey"
            columns: ["profile_id"]
            isOneToOne: false
            referencedRelation: "capability_profile"
            referencedColumns: ["id"]
          },
        ]
      }
      capability_version: {
        Row: {
          approval_policy: Json
          capability_id: string
          created_at: string
          eval_suite_id: string | null
          id: string
          lifecycle: string
          network_requirements: Json
          secret_requirements: Json
          version_label: string
        }
        Insert: {
          approval_policy?: Json
          capability_id: string
          created_at?: string
          eval_suite_id?: string | null
          id?: string
          lifecycle?: string
          network_requirements?: Json
          secret_requirements?: Json
          version_label: string
        }
        Update: {
          approval_policy?: Json
          capability_id?: string
          created_at?: string
          eval_suite_id?: string | null
          id?: string
          lifecycle?: string
          network_requirements?: Json
          secret_requirements?: Json
          version_label?: string
        }
        Relationships: [
          {
            foreignKeyName: "capability_version_capability_id_fkey"
            columns: ["capability_id"]
            isOneToOne: false
            referencedRelation: "capability"
            referencedColumns: ["id"]
          },
        ]
      }
      continuation_checkpoint: {
        Row: {
          active: Json
          agent_session_id: string | null
          blocked: Json
          completed: Json
          constraints_section: Json
          created_at: string
          decisions: Json
          digests: Json
          failed_approaches: Json
          id: string
          mission_id: string
          package_artifact_id: string | null
          pending_approvals: Json
          refs: Json
          verification_status: string
        }
        Insert: {
          active?: Json
          agent_session_id?: string | null
          blocked?: Json
          completed?: Json
          constraints_section?: Json
          created_at?: string
          decisions?: Json
          digests?: Json
          failed_approaches?: Json
          id?: string
          mission_id: string
          package_artifact_id?: string | null
          pending_approvals?: Json
          refs?: Json
          verification_status?: string
        }
        Update: {
          active?: Json
          agent_session_id?: string | null
          blocked?: Json
          completed?: Json
          constraints_section?: Json
          created_at?: string
          decisions?: Json
          digests?: Json
          failed_approaches?: Json
          id?: string
          mission_id?: string
          package_artifact_id?: string | null
          pending_approvals?: Json
          refs?: Json
          verification_status?: string
        }
        Relationships: [
          {
            foreignKeyName: "continuation_checkpoint_agent_session_id_fkey"
            columns: ["agent_session_id"]
            isOneToOne: false
            referencedRelation: "agent_session"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "continuation_checkpoint_mission_id_fkey"
            columns: ["mission_id"]
            isOneToOne: false
            referencedRelation: "mission"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "continuation_checkpoint_package_artifact_id_fkey"
            columns: ["package_artifact_id"]
            isOneToOne: false
            referencedRelation: "artifact"
            referencedColumns: ["id"]
          },
        ]
      }
      intent_type: {
        Row: {
          code: string
          created_at: string
          description: string
          schema_version: number
        }
        Insert: {
          code: string
          created_at?: string
          description: string
          schema_version?: number
        }
        Update: {
          code?: string
          created_at?: string
          description?: string
          schema_version?: number
        }
        Relationships: []
      }
      mission: {
        Row: {
          acceptance_criteria: Json
          budget_cost_usd: number | null
          budget_max_depth: number | null
          budget_max_fanout: number | null
          budget_max_retries: number | null
          budget_wall_seconds: number | null
          capability_profile_id: string | null
          created_at: string
          ended_at: string | null
          goal: string
          id: string
          research_questions: Json
          slug: string | null
          started_at: string | null
          status: Database["orchestration"]["Enums"]["mission_status"]
          tenant_id: string
          terminal_reason: string | null
          updated_at: string
        }
        Insert: {
          acceptance_criteria?: Json
          budget_cost_usd?: number | null
          budget_max_depth?: number | null
          budget_max_fanout?: number | null
          budget_max_retries?: number | null
          budget_wall_seconds?: number | null
          capability_profile_id?: string | null
          created_at?: string
          ended_at?: string | null
          goal: string
          id?: string
          research_questions?: Json
          slug?: string | null
          started_at?: string | null
          status?: Database["orchestration"]["Enums"]["mission_status"]
          tenant_id?: string
          terminal_reason?: string | null
          updated_at?: string
        }
        Update: {
          acceptance_criteria?: Json
          budget_cost_usd?: number | null
          budget_max_depth?: number | null
          budget_max_fanout?: number | null
          budget_max_retries?: number | null
          budget_wall_seconds?: number | null
          capability_profile_id?: string | null
          created_at?: string
          ended_at?: string | null
          goal?: string
          id?: string
          research_questions?: Json
          slug?: string | null
          started_at?: string | null
          status?: Database["orchestration"]["Enums"]["mission_status"]
          tenant_id?: string
          terminal_reason?: string | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "mission_capability_profile_fk"
            columns: ["capability_profile_id"]
            isOneToOne: false
            referencedRelation: "capability_profile"
            referencedColumns: ["id"]
          },
        ]
      }
      mission_event: {
        Row: {
          actor: string
          causation_id: string | null
          from_status:
            | Database["orchestration"]["Enums"]["mission_status"]
            | null
          id: string
          mission_id: string
          occurred_at: string
          payload: Json
          reason: string | null
          to_status: Database["orchestration"]["Enums"]["mission_status"]
        }
        Insert: {
          actor: string
          causation_id?: string | null
          from_status?:
            | Database["orchestration"]["Enums"]["mission_status"]
            | null
          id?: string
          mission_id: string
          occurred_at?: string
          payload?: Json
          reason?: string | null
          to_status: Database["orchestration"]["Enums"]["mission_status"]
        }
        Update: {
          actor?: string
          causation_id?: string | null
          from_status?:
            | Database["orchestration"]["Enums"]["mission_status"]
            | null
          id?: string
          mission_id?: string
          occurred_at?: string
          payload?: Json
          reason?: string | null
          to_status?: Database["orchestration"]["Enums"]["mission_status"]
        }
        Relationships: [
          {
            foreignKeyName: "mission_event_mission_id_fkey"
            columns: ["mission_id"]
            isOneToOne: false
            referencedRelation: "mission"
            referencedColumns: ["id"]
          },
        ]
      }
      operation_intent: {
        Row: {
          approval_state: string
          created_at: string
          id: string
          idempotency_key: string
          intent_type: string
          mc_activation_id: string | null
          mc_execution_generation: number | null
          mc_lane: string | null
          mc_mission_id: string | null
          mc_operation_attempt: number | null
          mc_operation_id: string | null
          mc_run_id: string | null
          mission_id: string | null
          origin_digest: string | null
          origin_kind: string | null
          payload: Json
          policy_decision: Json | null
          preconditions: Json
          proposed_by_attempt: string | null
          schema_version: number
          tenant_id: string
        }
        Insert: {
          approval_state?: string
          created_at?: string
          id?: string
          idempotency_key: string
          intent_type: string
          mc_activation_id?: string | null
          mc_execution_generation?: number | null
          mc_lane?: string | null
          mc_mission_id?: string | null
          mc_operation_attempt?: number | null
          mc_operation_id?: string | null
          mc_run_id?: string | null
          mission_id?: string | null
          origin_digest?: string | null
          origin_kind?: string | null
          payload: Json
          policy_decision?: Json | null
          preconditions?: Json
          proposed_by_attempt?: string | null
          schema_version?: number
          tenant_id?: string
        }
        Update: {
          approval_state?: string
          created_at?: string
          id?: string
          idempotency_key?: string
          intent_type?: string
          mc_activation_id?: string | null
          mc_execution_generation?: number | null
          mc_lane?: string | null
          mc_mission_id?: string | null
          mc_operation_attempt?: number | null
          mc_operation_id?: string | null
          mc_run_id?: string | null
          mission_id?: string | null
          origin_digest?: string | null
          origin_kind?: string | null
          payload?: Json
          policy_decision?: Json | null
          preconditions?: Json
          proposed_by_attempt?: string | null
          schema_version?: number
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "operation_intent_intent_type_fkey"
            columns: ["intent_type"]
            isOneToOne: false
            referencedRelation: "intent_type"
            referencedColumns: ["code"]
          },
          {
            foreignKeyName: "operation_intent_mission_id_fkey"
            columns: ["mission_id"]
            isOneToOne: false
            referencedRelation: "mission"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "operation_intent_proposed_by_attempt_fkey"
            columns: ["proposed_by_attempt"]
            isOneToOne: false
            referencedRelation: "attempt"
            referencedColumns: ["id"]
          },
        ]
      }
      operation_receipt: {
        Row: {
          affected_refs: Json
          applied_at: string
          bound_effect_digest: string | null
          changes_summary: Json
          executor_version: string
          id: string
          intent_id: string
          origin_digest: string | null
          outcome: string
          precondition_results: Json
          requires_admission: boolean
          use_decision_id: string | null
        }
        Insert: {
          affected_refs?: Json
          applied_at?: string
          bound_effect_digest?: string | null
          changes_summary?: Json
          executor_version: string
          id?: string
          intent_id: string
          origin_digest?: string | null
          outcome: string
          precondition_results?: Json
          requires_admission?: boolean
          use_decision_id?: string | null
        }
        Update: {
          affected_refs?: Json
          applied_at?: string
          bound_effect_digest?: string | null
          changes_summary?: Json
          executor_version?: string
          id?: string
          intent_id?: string
          origin_digest?: string | null
          outcome?: string
          precondition_results?: Json
          requires_admission?: boolean
          use_decision_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "operation_receipt_intent_id_fkey"
            columns: ["intent_id"]
            isOneToOne: true
            referencedRelation: "mission_run_effects"
            referencedColumns: ["intent_id"]
          },
          {
            foreignKeyName: "operation_receipt_intent_id_fkey"
            columns: ["intent_id"]
            isOneToOne: true
            referencedRelation: "operation_intent"
            referencedColumns: ["id"]
          },
        ]
      }
      operation_receipt_target: {
        Row: {
          action: string
          claim_id: string | null
          entity_id: string | null
          entity_kind: string | null
          ordinal: number
          proposal_id: string | null
          receipt_id: string
          role: string
          target_id: string
          target_schema: string
          target_table: string
          tenant_id: string
        }
        Insert: {
          action: string
          claim_id?: string | null
          entity_id?: string | null
          entity_kind?: string | null
          ordinal: number
          proposal_id?: string | null
          receipt_id: string
          role: string
          target_id: string
          target_schema: string
          target_table: string
          tenant_id?: string
        }
        Update: {
          action?: string
          claim_id?: string | null
          entity_id?: string | null
          entity_kind?: string | null
          ordinal?: number
          proposal_id?: string | null
          receipt_id?: string
          role?: string
          target_id?: string
          target_schema?: string
          target_table?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "operation_receipt_target_receipt_id_fkey"
            columns: ["receipt_id"]
            isOneToOne: false
            referencedRelation: "mission_run_effects"
            referencedColumns: ["receipt_id"]
          },
          {
            foreignKeyName: "operation_receipt_target_receipt_id_fkey"
            columns: ["receipt_id"]
            isOneToOne: false
            referencedRelation: "operation_receipt"
            referencedColumns: ["id"]
          },
        ]
      }
      outbox_event: {
        Row: {
          causation_id: string | null
          created_at: string
          id: number
          mission_id: string | null
          payload: Json
          published_at: string | null
          topic: string
        }
        Insert: {
          causation_id?: string | null
          created_at?: string
          id?: number
          mission_id?: string | null
          payload: Json
          published_at?: string | null
          topic: string
        }
        Update: {
          causation_id?: string | null
          created_at?: string
          id?: number
          mission_id?: string | null
          payload?: Json
          published_at?: string | null
          topic?: string
        }
        Relationships: [
          {
            foreignKeyName: "outbox_event_mission_id_fkey"
            columns: ["mission_id"]
            isOneToOne: false
            referencedRelation: "mission"
            referencedColumns: ["id"]
          },
        ]
      }
      provider_route: {
        Row: {
          abstract_operation: string
          created_at: string
          enabled: boolean
          failure_rollup: Json
          id: string
          policy_version: number
          priority: number
          provider: string
          selection_rules: Json
        }
        Insert: {
          abstract_operation: string
          created_at?: string
          enabled?: boolean
          failure_rollup?: Json
          id?: string
          policy_version?: number
          priority?: number
          provider: string
          selection_rules?: Json
        }
        Update: {
          abstract_operation?: string
          created_at?: string
          enabled?: boolean
          failure_rollup?: Json
          id?: string
          policy_version?: number
          priority?: number
          provider?: string
          selection_rules?: Json
        }
        Relationships: []
      }
      verification_artifact_metadata: {
        Row: {
          artifact_id: string
          attestation_artifact_id: string | null
          content_encoding: string | null
          created_at: string
          data_classification: string
          encryption_class: string
          logical_object_key: string | null
          parent_artifact_ids: string[]
          producer_activity_id: string
          producer_version: string
          retention_class: string
          tenant_id: string
          transformation_signature: string | null
        }
        Insert: {
          artifact_id: string
          attestation_artifact_id?: string | null
          content_encoding?: string | null
          created_at?: string
          data_classification: string
          encryption_class: string
          logical_object_key?: string | null
          parent_artifact_ids?: string[]
          producer_activity_id: string
          producer_version: string
          retention_class: string
          tenant_id?: string
          transformation_signature?: string | null
        }
        Update: {
          artifact_id?: string
          attestation_artifact_id?: string | null
          content_encoding?: string | null
          created_at?: string
          data_classification?: string
          encryption_class?: string
          logical_object_key?: string | null
          parent_artifact_ids?: string[]
          producer_activity_id?: string
          producer_version?: string
          retention_class?: string
          tenant_id?: string
          transformation_signature?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "verification_artifact_metadat_tenant_id_attestation_artifa_fkey"
            columns: ["tenant_id", "attestation_artifact_id"]
            isOneToOne: false
            referencedRelation: "artifact"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "verification_artifact_metadata_tenant_id_artifact_id_fkey"
            columns: ["tenant_id", "artifact_id"]
            isOneToOne: true
            referencedRelation: "artifact"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      verification_provider_attempt: {
        Row: {
          actual_cost_micros: number | null
          attempt_ordinal: number
          budget_id: string
          created_at: string
          dispatch_fence: string | null
          dispatch_fencing_token: number | null
          dispatched_at: string | null
          estimated_cost_micros: number | null
          id: string
          model: string
          operation_id: string | null
          operation_step_id: string | null
          profile_artifact_id: string | null
          profile_sha256: string | null
          provider_id: string
          reconciled_at: string | null
          request_artifact_id: string | null
          request_sha256: string
          reservation_cost_micros: number
          reserved_fencing_token: number | null
          response_artifact_id: string | null
          semantic_dispatch_holder_identity: string | null
          semantic_dispatch_lease_token: string | null
          semantic_request_sha256: string | null
          state: string
          tenant_id: string
        }
        Insert: {
          actual_cost_micros?: number | null
          attempt_ordinal: number
          budget_id: string
          created_at?: string
          dispatch_fence?: string | null
          dispatch_fencing_token?: number | null
          dispatched_at?: string | null
          estimated_cost_micros?: number | null
          id?: string
          model: string
          operation_id?: string | null
          operation_step_id?: string | null
          profile_artifact_id?: string | null
          profile_sha256?: string | null
          provider_id: string
          reconciled_at?: string | null
          request_artifact_id?: string | null
          request_sha256: string
          reservation_cost_micros: number
          reserved_fencing_token?: number | null
          response_artifact_id?: string | null
          semantic_dispatch_holder_identity?: string | null
          semantic_dispatch_lease_token?: string | null
          semantic_request_sha256?: string | null
          state: string
          tenant_id?: string
        }
        Update: {
          actual_cost_micros?: number | null
          attempt_ordinal?: number
          budget_id?: string
          created_at?: string
          dispatch_fence?: string | null
          dispatch_fencing_token?: number | null
          dispatched_at?: string | null
          estimated_cost_micros?: number | null
          id?: string
          model?: string
          operation_id?: string | null
          operation_step_id?: string | null
          profile_artifact_id?: string | null
          profile_sha256?: string | null
          provider_id?: string
          reconciled_at?: string | null
          request_artifact_id?: string | null
          request_sha256?: string
          reservation_cost_micros?: number
          reserved_fencing_token?: number | null
          response_artifact_id?: string | null
          semantic_dispatch_holder_identity?: string | null
          semantic_dispatch_lease_token?: string | null
          semantic_request_sha256?: string | null
          state?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "verification_provider_attempt_profile_artifact_tenant_fk"
            columns: ["tenant_id", "profile_artifact_id"]
            isOneToOne: false
            referencedRelation: "artifact"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "verification_provider_attempt_request_artifact_tenant_fkey"
            columns: ["tenant_id", "request_artifact_id"]
            isOneToOne: false
            referencedRelation: "artifact"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "verification_provider_attempt_response_artifact_tenant_fkey"
            columns: ["tenant_id", "response_artifact_id"]
            isOneToOne: false
            referencedRelation: "artifact"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "verification_provider_attempt_tenant_id_budget_id_fkey"
            columns: ["tenant_id", "budget_id"]
            isOneToOne: false
            referencedRelation: "verification_provider_budget"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      verification_provider_budget: {
        Row: {
          budget_key: string
          ceiling_cost_micros: number
          created_at: string
          id: string
          reserved_cost_micros: number
          settled_cost_micros: number
          tenant_id: string
          updated_at: string
        }
        Insert: {
          budget_key: string
          ceiling_cost_micros: number
          created_at?: string
          id?: string
          reserved_cost_micros?: number
          settled_cost_micros?: number
          tenant_id?: string
          updated_at?: string
        }
        Update: {
          budget_key?: string
          ceiling_cost_micros?: number
          created_at?: string
          id?: string
          reserved_cost_micros?: number
          settled_cost_micros?: number
          tenant_id?: string
          updated_at?: string
        }
        Relationships: []
      }
      verification_provider_reconciliation: {
        Row: {
          applied_at: string
          artifact_id: string
          artifact_sha256: string
          body: Json
          operation_id: string
          provider_attempt_id: string
          tenant_id: string
        }
        Insert: {
          applied_at?: string
          artifact_id: string
          artifact_sha256: string
          body: Json
          operation_id: string
          provider_attempt_id: string
          tenant_id: string
        }
        Update: {
          applied_at?: string
          artifact_id?: string
          artifact_sha256?: string
          body?: Json
          operation_id?: string
          provider_attempt_id?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "verification_provider_reconci_tenant_id_provider_attempt_i_fkey"
            columns: ["tenant_id", "provider_attempt_id"]
            isOneToOne: true
            referencedRelation: "verification_provider_attempt"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "verification_provider_reconciliation_tenant_id_artifact_id_fkey"
            columns: ["tenant_id", "artifact_id"]
            isOneToOne: true
            referencedRelation: "artifact"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      verification_provider_response_capture: {
        Row: {
          captured_at: string
          dispatch_fencing_token: number
          http_status: number
          operation_id: string
          operation_step_id: string
          profile_artifact_id: string
          profile_sha256: string
          provider_attempt_id: string
          response_envelope_artifact_id: string
          tenant_id: string
          transport_artifact_id: string
          transport_sha256: string
        }
        Insert: {
          captured_at?: string
          dispatch_fencing_token: number
          http_status: number
          operation_id: string
          operation_step_id: string
          profile_artifact_id: string
          profile_sha256: string
          provider_attempt_id: string
          response_envelope_artifact_id: string
          tenant_id: string
          transport_artifact_id: string
          transport_sha256: string
        }
        Update: {
          captured_at?: string
          dispatch_fencing_token?: number
          http_status?: number
          operation_id?: string
          operation_step_id?: string
          profile_artifact_id?: string
          profile_sha256?: string
          provider_attempt_id?: string
          response_envelope_artifact_id?: string
          tenant_id?: string
          transport_artifact_id?: string
          transport_sha256?: string
        }
        Relationships: [
          {
            foreignKeyName: "verification_provider_respons_tenant_id_profile_artifact_i_fkey"
            columns: ["tenant_id", "profile_artifact_id"]
            isOneToOne: false
            referencedRelation: "artifact"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "verification_provider_respons_tenant_id_provider_attempt_i_fkey"
            columns: ["tenant_id", "provider_attempt_id"]
            isOneToOne: true
            referencedRelation: "verification_provider_attempt"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "verification_provider_respons_tenant_id_response_envelope__fkey"
            columns: ["tenant_id", "response_envelope_artifact_id"]
            isOneToOne: false
            referencedRelation: "artifact"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "verification_provider_respons_tenant_id_transport_artifact_fkey"
            columns: ["tenant_id", "transport_artifact_id"]
            isOneToOne: false
            referencedRelation: "artifact"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      verification_semantic_response_observation: {
        Row: {
          blinded_input_artifact_id: string
          blinded_input_sha256: string
          completion_tokens: number | null
          dispatch_fencing_token: number
          model_status: string
          observation_artifact_id: string
          observation_sha256: string
          observed_model: string | null
          operation_id: string
          operation_step_id: string
          producer_attempt_id: string
          profile_artifact_id: string
          profile_sha256: string
          prompt_tokens: number | null
          provider_attempt_id: string
          raw_response_artifact_id: string
          raw_response_sha256: string
          recorded_at: string
          reported_cost_micros: number | null
          reported_cost_status: string
          request_artifact_id: string
          request_sha256: string
          requested_model: string
          response_envelope_artifact_id: string
          response_envelope_sha256: string
          revalidation_required: boolean
          tenant_id: string
          total_tokens: number | null
        }
        Insert: {
          blinded_input_artifact_id: string
          blinded_input_sha256: string
          completion_tokens?: number | null
          dispatch_fencing_token: number
          model_status: string
          observation_artifact_id: string
          observation_sha256: string
          observed_model?: string | null
          operation_id: string
          operation_step_id: string
          producer_attempt_id: string
          profile_artifact_id: string
          profile_sha256: string
          prompt_tokens?: number | null
          provider_attempt_id: string
          raw_response_artifact_id: string
          raw_response_sha256: string
          recorded_at?: string
          reported_cost_micros?: number | null
          reported_cost_status: string
          request_artifact_id: string
          request_sha256: string
          requested_model: string
          response_envelope_artifact_id: string
          response_envelope_sha256: string
          revalidation_required: boolean
          tenant_id: string
          total_tokens?: number | null
        }
        Update: {
          blinded_input_artifact_id?: string
          blinded_input_sha256?: string
          completion_tokens?: number | null
          dispatch_fencing_token?: number
          model_status?: string
          observation_artifact_id?: string
          observation_sha256?: string
          observed_model?: string | null
          operation_id?: string
          operation_step_id?: string
          producer_attempt_id?: string
          profile_artifact_id?: string
          profile_sha256?: string
          prompt_tokens?: number | null
          provider_attempt_id?: string
          raw_response_artifact_id?: string
          raw_response_sha256?: string
          recorded_at?: string
          reported_cost_micros?: number | null
          reported_cost_status?: string
          request_artifact_id?: string
          request_sha256?: string
          requested_model?: string
          response_envelope_artifact_id?: string
          response_envelope_sha256?: string
          revalidation_required?: boolean
          tenant_id?: string
          total_tokens?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "verification_semantic_respons_tenant_id_blinded_input_arti_fkey"
            columns: ["tenant_id", "blinded_input_artifact_id"]
            isOneToOne: false
            referencedRelation: "artifact"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "verification_semantic_respons_tenant_id_observation_artifa_fkey"
            columns: ["tenant_id", "observation_artifact_id"]
            isOneToOne: false
            referencedRelation: "artifact"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "verification_semantic_respons_tenant_id_producer_attempt_i_fkey"
            columns: ["tenant_id", "producer_attempt_id"]
            isOneToOne: false
            referencedRelation: "attempt"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "verification_semantic_respons_tenant_id_profile_artifact_i_fkey"
            columns: ["tenant_id", "profile_artifact_id"]
            isOneToOne: false
            referencedRelation: "artifact"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "verification_semantic_respons_tenant_id_provider_attempt_i_fkey"
            columns: ["tenant_id", "provider_attempt_id"]
            isOneToOne: true
            referencedRelation: "verification_provider_attempt"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "verification_semantic_respons_tenant_id_raw_response_artif_fkey"
            columns: ["tenant_id", "raw_response_artifact_id"]
            isOneToOne: false
            referencedRelation: "artifact"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "verification_semantic_respons_tenant_id_request_artifact_i_fkey"
            columns: ["tenant_id", "request_artifact_id"]
            isOneToOne: false
            referencedRelation: "artifact"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "verification_semantic_respons_tenant_id_response_envelope__fkey"
            columns: ["tenant_id", "response_envelope_artifact_id"]
            isOneToOne: false
            referencedRelation: "artifact"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      verification_structured_extraction: {
        Row: {
          candidate_artifact_id: string | null
          candidate_sha256: string | null
          capture_id: string
          captured_at: string | null
          completed_at: string | null
          http_status: number | null
          id: string
          identity_sha256: string
          operation_id: string
          operation_step_id: string
          original_dispatch_fencing_token: number | null
          precontext_artifact_id: string | null
          precontext_sha256: string | null
          producer_attempt_id: string
          profile_artifact_id: string
          profile_sha256: string
          prompt_sha256: string
          provenance_artifact_id: string | null
          provenance_sha256: string | null
          provider_attempt_id: string | null
          provider_request_artifact_id: string | null
          provider_request_sha256: string | null
          raw_response_artifact_id: string | null
          raw_response_sha256: string | null
          representation_artifact_id: string
          representation_sha256: string
          request_sha256: string
          response_envelope_artifact_id: string | null
          response_envelope_sha256: string | null
          retention_started_at: string | null
          schema_artifact_id: string
          schema_artifact_sha256: string
          schema_digest_sha256: string
          source_artifact_id: string
          source_sha256: string
          started_at: string
          status: string
          step_input_sha256: string
          tenant_id: string
          transformation_artifact_id: string
          transformation_sha256: string
          transport_artifact_id: string | null
          transport_sha256: string | null
        }
        Insert: {
          candidate_artifact_id?: string | null
          candidate_sha256?: string | null
          capture_id: string
          captured_at?: string | null
          completed_at?: string | null
          http_status?: number | null
          id?: string
          identity_sha256: string
          operation_id: string
          operation_step_id: string
          original_dispatch_fencing_token?: number | null
          precontext_artifact_id?: string | null
          precontext_sha256?: string | null
          producer_attempt_id: string
          profile_artifact_id: string
          profile_sha256: string
          prompt_sha256: string
          provenance_artifact_id?: string | null
          provenance_sha256?: string | null
          provider_attempt_id?: string | null
          provider_request_artifact_id?: string | null
          provider_request_sha256?: string | null
          raw_response_artifact_id?: string | null
          raw_response_sha256?: string | null
          representation_artifact_id: string
          representation_sha256: string
          request_sha256: string
          response_envelope_artifact_id?: string | null
          response_envelope_sha256?: string | null
          retention_started_at?: string | null
          schema_artifact_id: string
          schema_artifact_sha256: string
          schema_digest_sha256: string
          source_artifact_id: string
          source_sha256: string
          started_at?: string
          status?: string
          step_input_sha256: string
          tenant_id?: string
          transformation_artifact_id: string
          transformation_sha256: string
          transport_artifact_id?: string | null
          transport_sha256?: string | null
        }
        Update: {
          candidate_artifact_id?: string | null
          candidate_sha256?: string | null
          capture_id?: string
          captured_at?: string | null
          completed_at?: string | null
          http_status?: number | null
          id?: string
          identity_sha256?: string
          operation_id?: string
          operation_step_id?: string
          original_dispatch_fencing_token?: number | null
          precontext_artifact_id?: string | null
          precontext_sha256?: string | null
          producer_attempt_id?: string
          profile_artifact_id?: string
          profile_sha256?: string
          prompt_sha256?: string
          provenance_artifact_id?: string | null
          provenance_sha256?: string | null
          provider_attempt_id?: string | null
          provider_request_artifact_id?: string | null
          provider_request_sha256?: string | null
          raw_response_artifact_id?: string | null
          raw_response_sha256?: string | null
          representation_artifact_id?: string
          representation_sha256?: string
          request_sha256?: string
          response_envelope_artifact_id?: string | null
          response_envelope_sha256?: string | null
          retention_started_at?: string | null
          schema_artifact_id?: string
          schema_artifact_sha256?: string
          schema_digest_sha256?: string
          source_artifact_id?: string
          source_sha256?: string
          started_at?: string
          status?: string
          step_input_sha256?: string
          tenant_id?: string
          transformation_artifact_id?: string
          transformation_sha256?: string
          transport_artifact_id?: string | null
          transport_sha256?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "verification_structured_extra_tenant_id_candidate_artifact_fkey"
            columns: ["tenant_id", "candidate_artifact_id"]
            isOneToOne: false
            referencedRelation: "artifact"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "verification_structured_extra_tenant_id_precontext_artifac_fkey"
            columns: ["tenant_id", "precontext_artifact_id"]
            isOneToOne: false
            referencedRelation: "artifact"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "verification_structured_extra_tenant_id_producer_attempt_i_fkey"
            columns: ["tenant_id", "producer_attempt_id"]
            isOneToOne: false
            referencedRelation: "attempt"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "verification_structured_extra_tenant_id_profile_artifact_i_fkey"
            columns: ["tenant_id", "profile_artifact_id"]
            isOneToOne: false
            referencedRelation: "artifact"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "verification_structured_extra_tenant_id_provenance_artifac_fkey"
            columns: ["tenant_id", "provenance_artifact_id"]
            isOneToOne: false
            referencedRelation: "artifact"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "verification_structured_extra_tenant_id_provider_attempt_i_fkey"
            columns: ["tenant_id", "provider_attempt_id"]
            isOneToOne: true
            referencedRelation: "verification_provider_attempt"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "verification_structured_extra_tenant_id_provider_request_a_fkey"
            columns: ["tenant_id", "provider_request_artifact_id"]
            isOneToOne: false
            referencedRelation: "artifact"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "verification_structured_extra_tenant_id_raw_response_artif_fkey"
            columns: ["tenant_id", "raw_response_artifact_id"]
            isOneToOne: false
            referencedRelation: "artifact"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "verification_structured_extra_tenant_id_representation_art_fkey"
            columns: ["tenant_id", "representation_artifact_id"]
            isOneToOne: false
            referencedRelation: "artifact"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "verification_structured_extra_tenant_id_response_envelope__fkey"
            columns: ["tenant_id", "response_envelope_artifact_id"]
            isOneToOne: false
            referencedRelation: "artifact"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "verification_structured_extra_tenant_id_schema_artifact_id_fkey"
            columns: ["tenant_id", "schema_artifact_id"]
            isOneToOne: false
            referencedRelation: "artifact"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "verification_structured_extra_tenant_id_source_artifact_id_fkey"
            columns: ["tenant_id", "source_artifact_id"]
            isOneToOne: false
            referencedRelation: "artifact"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "verification_structured_extra_tenant_id_transformation_art_fkey"
            columns: ["tenant_id", "transformation_artifact_id"]
            isOneToOne: false
            referencedRelation: "artifact"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "verification_structured_extra_tenant_id_transport_artifact_fkey"
            columns: ["tenant_id", "transport_artifact_id"]
            isOneToOne: false
            referencedRelation: "artifact"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      verification_structured_extraction_execution: {
        Row: {
          bound_at: string
          dirty_artifact_id: string | null
          dirty_sha256: string | null
          execution_artifact_id: string
          execution_created_at: string
          execution_mode: string
          execution_sha256: string
          operation_id: string
          operation_step_id: string
          producer_attempt_id: string
          profile_artifact_id: string
          profile_sha256: string
          request_sha256: string
          runtime_sha256: string
          step_input_sha256: string
          tenant_id: string
        }
        Insert: {
          bound_at?: string
          dirty_artifact_id?: string | null
          dirty_sha256?: string | null
          execution_artifact_id: string
          execution_created_at: string
          execution_mode: string
          execution_sha256: string
          operation_id: string
          operation_step_id: string
          producer_attempt_id: string
          profile_artifact_id: string
          profile_sha256: string
          request_sha256: string
          runtime_sha256: string
          step_input_sha256: string
          tenant_id: string
        }
        Update: {
          bound_at?: string
          dirty_artifact_id?: string | null
          dirty_sha256?: string | null
          execution_artifact_id?: string
          execution_created_at?: string
          execution_mode?: string
          execution_sha256?: string
          operation_id?: string
          operation_step_id?: string
          producer_attempt_id?: string
          profile_artifact_id?: string
          profile_sha256?: string
          request_sha256?: string
          runtime_sha256?: string
          step_input_sha256?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "verification_structured_extr_tenant_id_producer_attempt_i_fkey1"
            columns: ["tenant_id", "producer_attempt_id"]
            isOneToOne: false
            referencedRelation: "attempt"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "verification_structured_extr_tenant_id_profile_artifact_i_fkey1"
            columns: ["tenant_id", "profile_artifact_id"]
            isOneToOne: false
            referencedRelation: "artifact"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "verification_structured_extra_tenant_id_execution_artifact_fkey"
            columns: ["tenant_id", "execution_artifact_id"]
            isOneToOne: false
            referencedRelation: "artifact"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "verification_structured_extrac_tenant_id_dirty_artifact_id_fkey"
            columns: ["tenant_id", "dirty_artifact_id"]
            isOneToOne: false
            referencedRelation: "artifact"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      verification_structured_extraction_failure: {
        Row: {
          completed_at: string
          failure_artifact_id: string | null
          failure_code: string
          failure_sha256: string | null
          operation_id: string
          provider_call_sha256: string | null
          seal_payload_sha256: string | null
          status: string
          tenant_id: string
        }
        Insert: {
          completed_at?: string
          failure_artifact_id?: string | null
          failure_code: string
          failure_sha256?: string | null
          operation_id: string
          provider_call_sha256?: string | null
          seal_payload_sha256?: string | null
          status?: string
          tenant_id: string
        }
        Update: {
          completed_at?: string
          failure_artifact_id?: string | null
          failure_code?: string
          failure_sha256?: string | null
          operation_id?: string
          provider_call_sha256?: string | null
          seal_payload_sha256?: string | null
          status?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "verification_structured_extra_tenant_id_failure_artifact_i_fkey"
            columns: ["tenant_id", "failure_artifact_id"]
            isOneToOne: false
            referencedRelation: "artifact"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "verification_structured_extraction_tenant_id_operation_id_fkey3"
            columns: ["tenant_id", "operation_id"]
            isOneToOne: true
            referencedRelation: "verification_structured_extraction"
            referencedColumns: ["tenant_id", "operation_id"]
          },
          {
            foreignKeyName: "verification_structured_extraction_tenant_id_operation_id_fkey4"
            columns: ["tenant_id", "operation_id"]
            isOneToOne: true
            referencedRelation: "verification_structured_extraction_execution"
            referencedColumns: ["tenant_id", "operation_id"]
          },
        ]
      }
      verification_structured_extraction_publication: {
        Row: {
          operation_id: string
          provider_call_sha256: string
          publication_artifact_id: string
          publication_sha256: string
          published_at: string
          seal_payload_sha256: string
          tenant_id: string
        }
        Insert: {
          operation_id: string
          provider_call_sha256: string
          publication_artifact_id: string
          publication_sha256: string
          published_at?: string
          seal_payload_sha256: string
          tenant_id: string
        }
        Update: {
          operation_id?: string
          provider_call_sha256?: string
          publication_artifact_id?: string
          publication_sha256?: string
          published_at?: string
          seal_payload_sha256?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "verification_structured_extra_tenant_id_publication_artifa_fkey"
            columns: ["tenant_id", "publication_artifact_id"]
            isOneToOne: false
            referencedRelation: "artifact"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "verification_structured_extraction_tenant_id_operation_id_fkey1"
            columns: ["tenant_id", "operation_id"]
            isOneToOne: true
            referencedRelation: "verification_structured_extraction"
            referencedColumns: ["tenant_id", "operation_id"]
          },
          {
            foreignKeyName: "verification_structured_extraction_tenant_id_operation_id_fkey2"
            columns: ["tenant_id", "operation_id"]
            isOneToOne: true
            referencedRelation: "verification_structured_extraction_execution"
            referencedColumns: ["tenant_id", "operation_id"]
          },
        ]
      }
      work_item: {
        Row: {
          attempt_count: number
          budget_cost_usd: number | null
          budget_wall_seconds: number | null
          capability_profile_id: string | null
          created_at: string
          heartbeat_at: string | null
          id: string
          idempotency_key: string | null
          kind: string
          lease_expires_at: string | null
          lease_owner: string | null
          max_attempts: number
          mission_id: string
          spec: Json
          status: Database["orchestration"]["Enums"]["work_item_status"]
          tenant_id: string
          terminal_evidence: Json | null
          updated_at: string
        }
        Insert: {
          attempt_count?: number
          budget_cost_usd?: number | null
          budget_wall_seconds?: number | null
          capability_profile_id?: string | null
          created_at?: string
          heartbeat_at?: string | null
          id?: string
          idempotency_key?: string | null
          kind: string
          lease_expires_at?: string | null
          lease_owner?: string | null
          max_attempts?: number
          mission_id: string
          spec?: Json
          status?: Database["orchestration"]["Enums"]["work_item_status"]
          tenant_id?: string
          terminal_evidence?: Json | null
          updated_at?: string
        }
        Update: {
          attempt_count?: number
          budget_cost_usd?: number | null
          budget_wall_seconds?: number | null
          capability_profile_id?: string | null
          created_at?: string
          heartbeat_at?: string | null
          id?: string
          idempotency_key?: string | null
          kind?: string
          lease_expires_at?: string | null
          lease_owner?: string | null
          max_attempts?: number
          mission_id?: string
          spec?: Json
          status?: Database["orchestration"]["Enums"]["work_item_status"]
          tenant_id?: string
          terminal_evidence?: Json | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "work_item_capability_profile_fk"
            columns: ["capability_profile_id"]
            isOneToOne: false
            referencedRelation: "capability_profile"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "work_item_kind_fkey"
            columns: ["kind"]
            isOneToOne: false
            referencedRelation: "work_item_kind"
            referencedColumns: ["code"]
          },
          {
            foreignKeyName: "work_item_mission_id_fkey"
            columns: ["mission_id"]
            isOneToOne: false
            referencedRelation: "mission"
            referencedColumns: ["id"]
          },
        ]
      }
      work_item_artifact: {
        Row: {
          artifact_id: string
          role: string
          work_item_id: string
        }
        Insert: {
          artifact_id: string
          role: string
          work_item_id: string
        }
        Update: {
          artifact_id?: string
          role?: string
          work_item_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "work_item_artifact_artifact_id_fkey"
            columns: ["artifact_id"]
            isOneToOne: false
            referencedRelation: "artifact"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "work_item_artifact_work_item_id_fkey"
            columns: ["work_item_id"]
            isOneToOne: false
            referencedRelation: "work_item"
            referencedColumns: ["id"]
          },
        ]
      }
      work_item_dependency: {
        Row: {
          created_at: string
          dependency_kind: string
          depends_on_id: string
          work_item_id: string
        }
        Insert: {
          created_at?: string
          dependency_kind?: string
          depends_on_id: string
          work_item_id: string
        }
        Update: {
          created_at?: string
          dependency_kind?: string
          depends_on_id?: string
          work_item_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "work_item_dependency_depends_on_id_fkey"
            columns: ["depends_on_id"]
            isOneToOne: false
            referencedRelation: "work_item"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "work_item_dependency_work_item_id_fkey"
            columns: ["work_item_id"]
            isOneToOne: false
            referencedRelation: "work_item"
            referencedColumns: ["id"]
          },
        ]
      }
      work_item_event: {
        Row: {
          actor: string
          attempt_id: string | null
          event_type: string
          id: string
          message: string | null
          occurred_at: string
          payload: Json
          tenant_id: string
          work_item_id: string
        }
        Insert: {
          actor: string
          attempt_id?: string | null
          event_type: string
          id?: string
          message?: string | null
          occurred_at?: string
          payload?: Json
          tenant_id?: string
          work_item_id: string
        }
        Update: {
          actor?: string
          attempt_id?: string | null
          event_type?: string
          id?: string
          message?: string | null
          occurred_at?: string
          payload?: Json
          tenant_id?: string
          work_item_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "work_item_event_attempt_id_fkey"
            columns: ["attempt_id"]
            isOneToOne: false
            referencedRelation: "attempt"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "work_item_event_work_item_id_fkey"
            columns: ["work_item_id"]
            isOneToOne: false
            referencedRelation: "work_item"
            referencedColumns: ["id"]
          },
        ]
      }
      work_item_kind: {
        Row: {
          code: string
          created_at: string
          description: string
        }
        Insert: {
          code: string
          created_at?: string
          description: string
        }
        Update: {
          code?: string
          created_at?: string
          description?: string
        }
        Relationships: []
      }
    }
    Views: {
      mission_run_effects: {
        Row: {
          action: string | null
          applied_at: string | null
          claim_id: string | null
          entity_id: string | null
          entity_kind: string | null
          intent_id: string | null
          mc_activation_id: string | null
          mc_execution_generation: number | null
          mc_lane: string | null
          mc_mission_id: string | null
          mc_operation_attempt: number | null
          mc_operation_id: string | null
          mc_run_id: string | null
          ordinal: number | null
          origin_digest: string | null
          proposal_id: string | null
          receipt_id: string | null
          receipt_outcome: string | null
          role: string | null
          target_id: string | null
          target_schema: string | null
          target_table: string | null
          tenant_id: string | null
          use_decision_id: string | null
        }
        Relationships: []
      }
    }
    Functions: {
      provider_reconciliation_handle_matches: {
        Args: { handle: Json; tenant: string }
        Returns: boolean
      }
      reconcile_legacy_artifact_custody: {
        Args: {
          p_bucket: string
          p_id: string
          p_sha256: string
          p_size: number
          p_tenant: string
        }
        Returns: undefined
      }
      structured_extraction_failure_result_body: {
        Args: { operation: string; tenant: string }
        Returns: Json
      }
      structured_extraction_receipt_json: {
        Args: { value: Json }
        Returns: string
      }
      structured_extraction_result_body: {
        Args: { operation: string; tenant: string }
        Returns: Json
      }
      verification_artifact_is_admitted: {
        Args: {
          p_artifact_id: string
          p_artifact_type?: string
          p_sha256?: string
          p_tenant_id: string
        }
        Returns: boolean
      }
      verification_provider_artifacts_are_admitted: {
        Args: {
          p_request_artifact_id: string
          p_request_sha256: string
          p_response_artifact_id: string
          p_tenant_id: string
        }
        Returns: boolean
      }
      verification_provider_scope_tuple_is_live: {
        Args: {
          p_claim: Json
          p_operation: string
          p_profile: string
          p_profile_sha: string
          p_step: string
          p_tenant: string
        }
        Returns: boolean
      }
      verification_structured_extraction_signature: {
        Args: {
          artifact_sha256: string
          artifact_type: string
          lifecycle: Database["orchestration"]["Tables"]["verification_structured_extraction"]["Row"]
          parents: string[]
        }
        Returns: string
      }
    }
    Enums: {
      attempt_outcome:
        | "succeeded"
        | "failed"
        | "timeout"
        | "cancelled"
        | "rejected"
      bucket_class:
        | "source_captures"
        | "candidate"
        | "accepted"
        | "ledger"
        | "published"
        | "workspace"
      mission_status:
        | "created"
        | "planning"
        | "running"
        | "paused"
        | "blocked"
        | "succeeded"
        | "failed"
        | "cancelled"
        | "superseded"
      work_item_status:
        | "pending"
        | "ready"
        | "running"
        | "blocked"
        | "succeeded"
        | "failed"
        | "cancelled"
        | "skipped"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  product: {
    Tables: {
      [_ in never]: never
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      actor: { Args: never; Returns: string }
      band: { Args: { p: string }; Returns: string }
      band_rank: { Args: { b: string }; Returns: number }
      can_read_offer: {
        Args: {
          o: Database["authoring"]["Tables"]["distribution_offer"]["Row"]
          p: string
        }
        Returns: boolean
      }
      check_cell_value: { Args: { ft: string; x: Json }; Returns: undefined }
      claims: { Args: never; Returns: Json }
      client_grant: {
        Args: { op_scope: string; ws: string }
        Returns: Database["access"]["Tables"]["client_grant"]["Row"]
        SetofOptions: {
          from: "*"
          to: "client_grant"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      dataset_close_cell: {
        Args: { dw: string; fk: string; n: number; rk: string }
        Returns: undefined
      }
      dataset_commit: {
        Args: {
          note: string
          origin: string
          p: string
          title: string
          w: Database["authoring"]["Tables"]["work"]["Row"]
          ws: string
        }
        Returns: string
      }
      dataset_content_sha256: {
        Args: { dw: string; n: number }
        Returns: string
      }
      dataset_draft_no: { Args: { dw: string }; Returns: number }
      dataset_edit: {
        Args: { dw: string; human: boolean; p: string; pl: Json; ws: string }
        Returns: number
      }
      dataset_snapshot: { Args: { dw: string; n: number }; Returns: Json }
      dataset_work: {
        Args: { dw: string; ws: string }
        Returns: Database["authoring"]["Tables"]["work"]["Row"]
        SetofOptions: {
          from: "*"
          to: "work"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      dispatch_authoring_command: {
        Args: {
          g: Database["access"]["Tables"]["client_grant"]["Row"]
          head: string
          op: string
          p: string
          pl: Json
          ws: string
        }
        Returns: Json
      }
      dispatch_authoring_read: {
        Args: {
          g: Database["access"]["Tables"]["client_grant"]["Row"]
          op: string
          p: string
          pl: Json
          ws: string
        }
        Returns: Json
      }
      dispatch_command: {
        Args: {
          g: Database["access"]["Tables"]["client_grant"]["Row"]
          head: string
          op: string
          p: string
          pl: Json
          ws: string
        }
        Returns: Json
      }
      dispatch_read: {
        Args: { op: string; p: string; pl: Json; ws: string }
        Returns: Json
      }
      dispatch_research_command: {
        Args: {
          g: Database["access"]["Tables"]["client_grant"]["Row"]
          head: string
          human: boolean
          op: string
          p: string
          pl: Json
          surface: string
          ws: string
        }
        Returns: Json
      }
      dispatch_research_read: {
        Args: { op: string; p: string; pl: Json; ws: string }
        Returns: Json
      }
      dispatch_worker: { Args: { op: string; pl: Json }; Returns: Json }
      exposure: { Args: { ceiling: string; root_rev: string }; Returns: Json }
      fail: { Args: { code: string; detail?: string }; Returns: undefined }
      finalize: {
        Args: { how: string; policy: string; result_id: string }
        Returns: undefined
      }
      insert_revision: {
        Args: {
          p: string
          parent: string
          spec: Json
          w: Database["authoring"]["Tables"]["work"]["Row"]
          ws: string
        }
        Returns: string
      }
      new_event: {
        Args: {
          actor_kind: string
          dedupe: string
          kind: string
          p: string
          payload: Json
          rev: string
          role: string
          surface: string
          work: string
          ws: string
        }
        Returns: string
      }
      nonblank: { Args: { t: string }; Returns: boolean }
      personal_workspace: { Args: { p: string }; Returns: string }
      policy: { Args: never; Returns: Json }
      processing_allowed: {
        Args: { cls: string; p: string; pkey: string }
        Returns: boolean
      }
      proposal_problems: { Args: { m: Json }; Returns: Json }
      readable_revision: { Args: { p: string; rid: string }; Returns: boolean }
      register_artifact: {
        Args: {
          atype: string
          media: string
          p: string
          retention?: string
          rights: string
          sha: string
          size: number
          ttl?: string
          usage: string
          ws: string
        }
        Returns: string
      }
      require_role: {
        Args: { allowed: string[]; p: string; ws: string }
        Returns: string
      }
      restricted: {
        Args: { art: string; cap: string; effects: string[] }
        Returns: boolean
      }
      revision_digest: { Args: { rid: string }; Returns: string }
      role_in: { Args: { p: string; ws: string }; Returns: string }
      session_reader: { Args: never; Returns: Record<string, unknown> }
      session_reads_revision: { Args: { rid: string }; Returns: boolean }
      session_reads_workspace: { Args: { ws: string }; Returns: boolean }
      sha256_text: { Args: { t: string }; Returns: string }
      support_counts: { Args: { aid: string; cid: string }; Returns: Json }
      support_detail: {
        Args: { p: string; s: Database["inquiry"]["Tables"]["support"]["Row"] }
        Returns: Json
      }
      tenant: { Args: never; Returns: string }
      validate_body: { Args: { body: Json; kind: string }; Returns: undefined }
      walk_blocks: {
        Args: { blocks: Json; p: string; parent: string; rid: string }
        Returns: undefined
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  public: {
    Tables: {
      [_ in never]: never
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      research_category_assignment_role: "primary" | "secondary"
      research_content_form:
        | "talk"
        | "tutorial"
        | "demo"
        | "panel"
        | "interview"
        | "workshop"
        | "keynote"
      research_difficulty:
        | "introductory"
        | "intermediate"
        | "advanced"
        | "expert"
      research_engineering_category_code:
        | "model_foundations_behavior"
        | "inference_model_systems"
        | "ai_data_engineering"
        | "post_training_continual_learning"
        | "prompting_llm_programming"
        | "context_engineering_memory"
        | "retrieval_search_knowledge"
        | "agent_architecture_harnesses"
        | "tools_protocols_integrations"
        | "orchestration_durable_execution"
        | "coding_agents_software_engineering"
        | "evaluation_testing_benchmarking"
        | "observability_reliability_llmops"
        | "security_safety_identity_governance"
        | "multimodal_realtime_systems"
        | "ai_product_ux_human_factors"
        | "ai_platforms_developer_tooling"
        | "model_behavior"
        | "inference_serving"
        | "training_and_post_training"
        | "data_for_models"
        | "prompting"
        | "context_and_memory"
        | "retrieval_and_search"
        | "single_agent_loops"
        | "multi_agent_coordination"
        | "agent_harnesses"
        | "tools_and_protocols"
        | "durable_workflows"
        | "coding_agents"
        | "evaluation"
        | "observability_and_ops"
        | "security_and_governance"
        | "voice_and_speech"
        | "vision_multimodal_robotics"
        | "product_ux"
        | "platforms_and_gateways"
        | "research_automation"
        | "org_adoption"
        | "multi_talk_compilation"
        | "insufficient_evidence"
      research_entity_kind:
        | "person"
        | "organization"
        | "product"
        | "model"
        | "protocol"
        | "dataset"
        | "benchmark"
        | "paper"
        | "repository"
        | "other"
      research_evidence_level:
        | "anecdotal"
        | "case_study"
        | "benchmarked"
        | "production_system"
        | "research_paper"
      research_evidence_source_kind: "transcript" | "description" | "web"
      research_intent_event_status: "pending" | "applied" | "skipped" | "failed"
      research_intent_status: "draft" | "validated" | "applied" | "rejected"
      research_lifecycle_stage:
        | "research"
        | "design"
        | "implementation"
        | "evaluation"
        | "deployment"
        | "operations"
        | "governance"
      research_organization_domain_code:
        | "frontier_model_lab"
        | "applied_ai_research_lab"
        | "cloud_ai_platform"
        | "ai_compute_hardware_systems"
        | "model_training_inference_platform"
        | "ai_data_curation_training_platform"
        | "database_data_ai_platform"
        | "retrieval_knowledge_platform"
        | "agent_framework_orchestration"
        | "ai_developer_platform_sdk"
        | "coding_agents_developer_tools"
        | "evaluation_observability_llmops"
        | "ai_security_identity_governance"
        | "multimodal_voice_media_ai"
        | "robotics_embodied_edge_ai"
        | "enterprise_ai_automation"
        | "horizontal_ai_application"
        | "vertical_ai_application"
        | "open_source_ai_ecosystem"
        | "ai_protocol_standards_body"
        | "academic_nonprofit_research"
        | "ai_services_consulting"
        | "ai_community_education_media"
        | "ai_adopting_product_company"
        | "general_technology_ai_unit"
        | "diversified_technology_company"
        | "other_unknown"
      research_organization_scope:
        | "independent_company"
        | "parent_company"
        | "subsidiary"
        | "division"
        | "research_lab"
        | "product_organization"
        | "standards_body"
        | "academic_institution"
        | "nonprofit"
        | "community_education_media"
        | "other"
      research_pre_research_run_status:
        | "queued"
        | "claimed"
        | "analyzing"
        | "intent_ready"
        | "applying"
        | "applied"
        | "review_required"
        | "failed"
        | "superseded"
        | "research_complete"
        | "synthesizing"
      research_resource_type:
        | "repository"
        | "code_example"
        | "documentation"
        | "paper"
        | "article"
        | "slides"
        | "dataset"
        | "benchmark"
        | "model"
        | "demo"
        | "course"
        | "other"
      research_taxonomy_status: "draft" | "active" | "retired"
      research_verification_status:
        | "verified"
        | "likely"
        | "uncertain"
        | "rejected"
      research_video_organization_role:
        | "primary_featured_organization"
        | "implementation_owner"
        | "speaker_employer"
        | "parent_organization"
        | "subsidiary_or_division"
        | "acquisition_party"
        | "partner"
        | "customer_or_internal_user"
        | "standards_steward"
        | "mentioned_only"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  ranking: {
    Tables: {
      leaderboard: {
        Row: {
          benchmark_version_id: string | null
          created_at: string
          definition: Json
          description: string | null
          id: string
          methodology: Json
          publisher_entity_id: string | null
          slug: string
          source_url: string | null
          tenant_id: string
          title: string
        }
        Insert: {
          benchmark_version_id?: string | null
          created_at?: string
          definition?: Json
          description?: string | null
          id?: string
          methodology?: Json
          publisher_entity_id?: string | null
          slug: string
          source_url?: string | null
          tenant_id?: string
          title?: string
        }
        Update: {
          benchmark_version_id?: string | null
          created_at?: string
          definition?: Json
          description?: string | null
          id?: string
          methodology?: Json
          publisher_entity_id?: string | null
          slug?: string
          source_url?: string | null
          tenant_id?: string
          title?: string
        }
        Relationships: []
      }
      leaderboard_edition: {
        Row: {
          board_date: string | null
          capture_id: string | null
          cohort: Json
          edition_no: number
          id: string
          knowledge_seq: number | null
          leaderboard_id: string
          observed_at: string | null
          published_at: string
          tenant_id: string
        }
        Insert: {
          board_date?: string | null
          capture_id?: string | null
          cohort?: Json
          edition_no: number
          id?: string
          knowledge_seq?: number | null
          leaderboard_id: string
          observed_at?: string | null
          published_at?: string
          tenant_id?: string
        }
        Update: {
          board_date?: string | null
          capture_id?: string | null
          cohort?: Json
          edition_no?: number
          id?: string
          knowledge_seq?: number | null
          leaderboard_id?: string
          observed_at?: string | null
          published_at?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "leaderboard_edition_leaderboard_id_fkey"
            columns: ["leaderboard_id"]
            isOneToOne: false
            referencedRelation: "leaderboard"
            referencedColumns: ["id"]
          },
        ]
      }
      leaderboard_entry: {
        Row: {
          conditions: Json
          edition_id: string
          entity_id: string
          explanation: Json
          node_id: string | null
          rank: number
          score: number | null
          source_segment_ids: string[]
          subject_label: string | null
          tenant_id: string
          unit: string | null
        }
        Insert: {
          conditions?: Json
          edition_id: string
          entity_id: string
          explanation?: Json
          node_id?: string | null
          rank: number
          score?: number | null
          source_segment_ids?: string[]
          subject_label?: string | null
          tenant_id?: string
          unit?: string | null
        }
        Update: {
          conditions?: Json
          edition_id?: string
          entity_id?: string
          explanation?: Json
          node_id?: string | null
          rank?: number
          score?: number | null
          source_segment_ids?: string[]
          subject_label?: string | null
          tenant_id?: string
          unit?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "leaderboard_entry_edition_id_fkey"
            columns: ["edition_id"]
            isOneToOne: false
            referencedRelation: "leaderboard_edition"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      approval_state:
        | "draft"
        | "proposed"
        | "approved"
        | "deprecated"
        | "rejected"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  retrieval: {
    Tables: {
      authorized_publication_execution: {
        Row: {
          action: string
          created_at: string
          guarded_sha256: string
          id: string
          operation_id: string
          publisher_identity: string
          switch_receipt_id: string
          tenant_id: string
        }
        Insert: {
          action: string
          created_at?: string
          guarded_sha256: string
          id?: string
          operation_id: string
          publisher_identity: string
          switch_receipt_id: string
          tenant_id?: string
        }
        Update: {
          action?: string
          created_at?: string
          guarded_sha256?: string
          id?: string
          operation_id?: string
          publisher_identity?: string
          switch_receipt_id?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "authorized_publication_executi_tenant_id_switch_receipt_id_fkey"
            columns: ["tenant_id", "switch_receipt_id"]
            isOneToOne: false
            referencedRelation: "publication_switch_receipt"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      chunk_claim_link: {
        Row: {
          chunk_id: string
          claim_id: string
          tenant_id: string
          verb: string
        }
        Insert: {
          chunk_id: string
          claim_id: string
          tenant_id?: string
          verb: string
        }
        Update: {
          chunk_id?: string
          claim_id?: string
          tenant_id?: string
          verb?: string
        }
        Relationships: [
          {
            foreignKeyName: "chunk_claim_link_chunk_id_fkey"
            columns: ["chunk_id"]
            isOneToOne: false
            referencedRelation: "retrieval_chunk"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "chunk_claim_link_tenant_id_chunk_id_fkey"
            columns: ["tenant_id", "chunk_id"]
            isOneToOne: false
            referencedRelation: "retrieval_chunk"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      chunk_edge: {
        Row: {
          created_at: string
          from_chunk_id: string
          metadata: Json
          relation_kind: string
          tenant_id: string
          to_chunk_id: string
        }
        Insert: {
          created_at?: string
          from_chunk_id: string
          metadata?: Json
          relation_kind: string
          tenant_id?: string
          to_chunk_id: string
        }
        Update: {
          created_at?: string
          from_chunk_id?: string
          metadata?: Json
          relation_kind?: string
          tenant_id?: string
          to_chunk_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "chunk_edge_tenant_id_from_chunk_id_fkey"
            columns: ["tenant_id", "from_chunk_id"]
            isOneToOne: false
            referencedRelation: "retrieval_chunk"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "chunk_edge_tenant_id_to_chunk_id_fkey"
            columns: ["tenant_id", "to_chunk_id"]
            isOneToOne: false
            referencedRelation: "retrieval_chunk"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      chunk_entity_mention: {
        Row: {
          chunk_id: string
          confidence: number | null
          entity_id: string
          method: string
          tenant_id: string
          verb: string
        }
        Insert: {
          chunk_id: string
          confidence?: number | null
          entity_id: string
          method: string
          tenant_id?: string
          verb: string
        }
        Update: {
          chunk_id?: string
          confidence?: number | null
          entity_id?: string
          method?: string
          tenant_id?: string
          verb?: string
        }
        Relationships: [
          {
            foreignKeyName: "chunk_entity_mention_chunk_id_fkey"
            columns: ["chunk_id"]
            isOneToOne: false
            referencedRelation: "retrieval_chunk"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "chunk_entity_mention_tenant_id_chunk_id_fkey"
            columns: ["tenant_id", "chunk_id"]
            isOneToOne: false
            referencedRelation: "retrieval_chunk"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      chunk_relationship_evidence: {
        Row: {
          chunk_id: string
          relationship_id: string
          tenant_id: string
          verb: string
        }
        Insert: {
          chunk_id: string
          relationship_id: string
          tenant_id?: string
          verb: string
        }
        Update: {
          chunk_id?: string
          relationship_id?: string
          tenant_id?: string
          verb?: string
        }
        Relationships: [
          {
            foreignKeyName: "chunk_relationship_evidence_chunk_id_fkey"
            columns: ["chunk_id"]
            isOneToOne: false
            referencedRelation: "retrieval_chunk"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "chunk_relationship_evidence_tenant_id_chunk_id_fkey"
            columns: ["tenant_id", "chunk_id"]
            isOneToOne: false
            referencedRelation: "retrieval_chunk"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      chunk_set: {
        Row: {
          chunk_set_sha256: string
          created_at: string
          frozen_config: Json
          id: string
          input_manifest_sha256: string
          output_manifest_sha256: string | null
          procedure_version_id: string
          promotion_decision_id: string | null
          qa_evaluation_id: string | null
          representation_id: string
          status: string
          supersedes_id: string | null
          tenant_id: string
          tokenizer: string
        }
        Insert: {
          chunk_set_sha256: string
          created_at?: string
          frozen_config: Json
          id?: string
          input_manifest_sha256: string
          output_manifest_sha256?: string | null
          procedure_version_id: string
          promotion_decision_id?: string | null
          qa_evaluation_id?: string | null
          representation_id: string
          status?: string
          supersedes_id?: string | null
          tenant_id?: string
          tokenizer: string
        }
        Update: {
          chunk_set_sha256?: string
          created_at?: string
          frozen_config?: Json
          id?: string
          input_manifest_sha256?: string
          output_manifest_sha256?: string | null
          procedure_version_id?: string
          promotion_decision_id?: string | null
          qa_evaluation_id?: string | null
          representation_id?: string
          status?: string
          supersedes_id?: string | null
          tenant_id?: string
          tokenizer?: string
        }
        Relationships: [
          {
            foreignKeyName: "chunk_set_tenant_id_procedure_version_id_fkey"
            columns: ["tenant_id", "procedure_version_id"]
            isOneToOne: false
            referencedRelation: "chunking_procedure_version"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "chunk_set_tenant_id_supersedes_id_fkey"
            columns: ["tenant_id", "supersedes_id"]
            isOneToOne: false
            referencedRelation: "chunk_set"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      chunk_span: {
        Row: {
          chunk_id: string
          created_at: string
          document_node_id: string
          end_offset: number | null
          locator_id: string | null
          ordinal: number
          selected_text_sha256: string
          start_offset: number | null
          tenant_id: string
        }
        Insert: {
          chunk_id: string
          created_at?: string
          document_node_id: string
          end_offset?: number | null
          locator_id?: string | null
          ordinal: number
          selected_text_sha256: string
          start_offset?: number | null
          tenant_id?: string
        }
        Update: {
          chunk_id?: string
          created_at?: string
          document_node_id?: string
          end_offset?: number | null
          locator_id?: string | null
          ordinal?: number
          selected_text_sha256?: string
          start_offset?: number | null
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "chunk_span_tenant_id_chunk_id_fkey"
            columns: ["tenant_id", "chunk_id"]
            isOneToOne: false
            referencedRelation: "retrieval_chunk"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      chunking_procedure_version: {
        Row: {
          capability_version_id: string | null
          code_sha256: string
          container_sha256: string | null
          created_at: string
          defaults: Json
          id: string
          limits: Json
          overlap_tokens: number | null
          respect_boundaries: boolean
          schema_contract: Json
          slug: string
          status: string
          strategy: string | null
          supported_content_classes: Json
          target_tokens: number | null
          tenant_id: string
          tokenizer: string
          version: string
        }
        Insert: {
          capability_version_id?: string | null
          code_sha256: string
          container_sha256?: string | null
          created_at?: string
          defaults?: Json
          id?: string
          limits?: Json
          overlap_tokens?: number | null
          respect_boundaries?: boolean
          schema_contract: Json
          slug: string
          status: string
          strategy?: string | null
          supported_content_classes: Json
          target_tokens?: number | null
          tenant_id?: string
          tokenizer: string
          version: string
        }
        Update: {
          capability_version_id?: string | null
          code_sha256?: string
          container_sha256?: string | null
          created_at?: string
          defaults?: Json
          id?: string
          limits?: Json
          overlap_tokens?: number | null
          respect_boundaries?: boolean
          schema_contract?: Json
          slug?: string
          status?: string
          strategy?: string | null
          supported_content_classes?: Json
          target_tokens?: number | null
          tenant_id?: string
          tokenizer?: string
          version?: string
        }
        Relationships: []
      }
      content_promotion_decision: {
        Row: {
          created_at: string
          decision: string
          decision_operation_id: string | null
          expires_at: string | null
          gates: Json
          guarded_sha256: string
          id: string
          knowledge_review_decision_id: string | null
          legacy_provenance: boolean
          policy_version: string
          proposal_id: string
          rationale: string
          reviewer_identity: string
          tenant_id: string
        }
        Insert: {
          created_at?: string
          decision: string
          decision_operation_id?: string | null
          expires_at?: string | null
          gates: Json
          guarded_sha256: string
          id?: string
          knowledge_review_decision_id?: string | null
          legacy_provenance?: boolean
          policy_version: string
          proposal_id: string
          rationale: string
          reviewer_identity: string
          tenant_id?: string
        }
        Update: {
          created_at?: string
          decision?: string
          decision_operation_id?: string | null
          expires_at?: string | null
          gates?: Json
          guarded_sha256?: string
          id?: string
          knowledge_review_decision_id?: string | null
          legacy_provenance?: boolean
          policy_version?: string
          proposal_id?: string
          rationale?: string
          reviewer_identity?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "content_promotion_decision_tenant_id_proposal_id_fkey"
            columns: ["tenant_id", "proposal_id"]
            isOneToOne: false
            referencedRelation: "content_promotion_proposal"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      content_promotion_proposal: {
        Row: {
          chunk_manifest: Json
          created_at: string
          exclusions: string[]
          expected_value: string
          id: string
          legacy_provenance: boolean
          operation_id: string | null
          procedures: Json
          projection_manifest: Json
          proposal_sha256: string
          proposed_by: string
          reason: string
          risks: string[]
          source_manifest: Json
          target_domains: string[]
          tenant_id: string
        }
        Insert: {
          chunk_manifest: Json
          created_at?: string
          exclusions?: string[]
          expected_value: string
          id?: string
          legacy_provenance?: boolean
          operation_id?: string | null
          procedures: Json
          projection_manifest: Json
          proposal_sha256: string
          proposed_by: string
          reason: string
          risks?: string[]
          source_manifest: Json
          target_domains: string[]
          tenant_id?: string
        }
        Update: {
          chunk_manifest?: Json
          created_at?: string
          exclusions?: string[]
          expected_value?: string
          id?: string
          legacy_provenance?: boolean
          operation_id?: string | null
          procedures?: Json
          projection_manifest?: Json
          proposal_sha256?: string
          proposed_by?: string
          reason?: string
          risks?: string[]
          source_manifest?: Json
          target_domains?: string[]
          tenant_id?: string
        }
        Relationships: []
      }
      embedding_item: {
        Row: {
          cache_key: string
          created_at: string
          dimensions: number
          embedding_run_id: string
          id: string
          input_sha256: string
          output_sha256: string
          provider_metadata: Json
          search_projection_id: string
          status: string
          tenant_id: string
        }
        Insert: {
          cache_key: string
          created_at?: string
          dimensions: number
          embedding_run_id: string
          id?: string
          input_sha256: string
          output_sha256: string
          provider_metadata?: Json
          search_projection_id: string
          status: string
          tenant_id?: string
        }
        Update: {
          cache_key?: string
          created_at?: string
          dimensions?: number
          embedding_run_id?: string
          id?: string
          input_sha256?: string
          output_sha256?: string
          provider_metadata?: Json
          search_projection_id?: string
          status?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "embedding_item_tenant_id_embedding_run_id_fkey"
            columns: ["tenant_id", "embedding_run_id"]
            isOneToOne: false
            referencedRelation: "embedding_run"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "embedding_item_tenant_id_search_projection_id_fkey"
            columns: ["tenant_id", "search_projection_id"]
            isOneToOne: false
            referencedRelation: "search_projection"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      embedding_run: {
        Row: {
          adapter_version: string
          completed_at: string | null
          cost_usd: number | null
          created_at: string
          expected_dimensions: number
          failure_class: string | null
          gateway_model_slug: string
          id: string
          idempotency_key: string
          input_manifest_sha256: string
          latency_ms: number | null
          legacy_provenance: boolean
          observed_provider_route: string | null
          operation_id: string | null
          output_manifest_sha256: string | null
          promotion_decision_id: string | null
          provider_route_policy: Json
          receipt: Json | null
          request_id: string | null
          retry_history: Json
          status: string
          tenant_id: string
          usage: Json
          vector_space_version_id: string
        }
        Insert: {
          adapter_version: string
          completed_at?: string | null
          cost_usd?: number | null
          created_at?: string
          expected_dimensions: number
          failure_class?: string | null
          gateway_model_slug: string
          id?: string
          idempotency_key: string
          input_manifest_sha256: string
          latency_ms?: number | null
          legacy_provenance?: boolean
          observed_provider_route?: string | null
          operation_id?: string | null
          output_manifest_sha256?: string | null
          promotion_decision_id?: string | null
          provider_route_policy: Json
          receipt?: Json | null
          request_id?: string | null
          retry_history?: Json
          status?: string
          tenant_id?: string
          usage?: Json
          vector_space_version_id: string
        }
        Update: {
          adapter_version?: string
          completed_at?: string | null
          cost_usd?: number | null
          created_at?: string
          expected_dimensions?: number
          failure_class?: string | null
          gateway_model_slug?: string
          id?: string
          idempotency_key?: string
          input_manifest_sha256?: string
          latency_ms?: number | null
          legacy_provenance?: boolean
          observed_provider_route?: string | null
          operation_id?: string | null
          output_manifest_sha256?: string | null
          promotion_decision_id?: string | null
          provider_route_policy?: Json
          receipt?: Json | null
          request_id?: string | null
          retry_history?: Json
          status?: string
          tenant_id?: string
          usage?: Json
          vector_space_version_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "embedding_run_promotion_decision_fk"
            columns: ["tenant_id", "promotion_decision_id"]
            isOneToOne: false
            referencedRelation: "content_promotion_decision"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "embedding_run_tenant_id_vector_space_version_id_fkey"
            columns: ["tenant_id", "vector_space_version_id"]
            isOneToOne: false
            referencedRelation: "vector_space_version"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      evidence_packet: {
        Row: {
          abstention: Json | null
          artifact_id: string | null
          authorization_context: Json | null
          coverage: Json
          created_at: string
          event_ids: string[]
          id: string
          normalized_query: string | null
          omitted_results: Json
          packet: Json
          packet_schema_version: number
          packet_sha256: string | null
          receipt_ids: string[]
          run_id: string | null
          tenant_id: string
        }
        Insert: {
          abstention?: Json | null
          artifact_id?: string | null
          authorization_context?: Json | null
          coverage?: Json
          created_at?: string
          event_ids?: string[]
          id?: string
          normalized_query?: string | null
          omitted_results?: Json
          packet: Json
          packet_schema_version?: number
          packet_sha256?: string | null
          receipt_ids?: string[]
          run_id?: string | null
          tenant_id?: string
        }
        Update: {
          abstention?: Json | null
          artifact_id?: string | null
          authorization_context?: Json | null
          coverage?: Json
          created_at?: string
          event_ids?: string[]
          id?: string
          normalized_query?: string | null
          omitted_results?: Json
          packet?: Json
          packet_schema_version?: number
          packet_sha256?: string | null
          receipt_ids?: string[]
          run_id?: string | null
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "evidence_packet_run_id_fkey"
            columns: ["run_id"]
            isOneToOne: false
            referencedRelation: "retrieval_run"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "evidence_packet_tenant_run_fk"
            columns: ["tenant_id", "run_id"]
            isOneToOne: false
            referencedRelation: "retrieval_run"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      packet_member: {
        Row: {
          artifact_references: Json
          assurance: string | null
          authority: string | null
          channel_explanations: string[]
          claim_id: string | null
          contradiction_flags: Json
          contradiction_ids: string[]
          coverage_role: string | null
          covered_subquery_ids: string[]
          created_at: string
          fresh_at: string | null
          freshness: string | null
          graph_paths: Json
          guidance_item_id: string | null
          id: string
          locators: Json
          member_kind: string | null
          member_payload: Json
          member_sha256: string | null
          packet_id: string
          scores: Json
          search_projection_id: string | null
          source_document_node_id: string | null
          source_representation_id: string | null
          supersedes_ids: string[]
          tenant_id: string
          vector_item_id: string | null
          verification_state: string | null
        }
        Insert: {
          artifact_references?: Json
          assurance?: string | null
          authority?: string | null
          channel_explanations?: string[]
          claim_id?: string | null
          contradiction_flags?: Json
          contradiction_ids?: string[]
          coverage_role?: string | null
          covered_subquery_ids?: string[]
          created_at?: string
          fresh_at?: string | null
          freshness?: string | null
          graph_paths?: Json
          guidance_item_id?: string | null
          id?: string
          locators?: Json
          member_kind?: string | null
          member_payload?: Json
          member_sha256?: string | null
          packet_id: string
          scores?: Json
          search_projection_id?: string | null
          source_document_node_id?: string | null
          source_representation_id?: string | null
          supersedes_ids?: string[]
          tenant_id?: string
          vector_item_id?: string | null
          verification_state?: string | null
        }
        Update: {
          artifact_references?: Json
          assurance?: string | null
          authority?: string | null
          channel_explanations?: string[]
          claim_id?: string | null
          contradiction_flags?: Json
          contradiction_ids?: string[]
          coverage_role?: string | null
          covered_subquery_ids?: string[]
          created_at?: string
          fresh_at?: string | null
          freshness?: string | null
          graph_paths?: Json
          guidance_item_id?: string | null
          id?: string
          locators?: Json
          member_kind?: string | null
          member_payload?: Json
          member_sha256?: string | null
          packet_id?: string
          scores?: Json
          search_projection_id?: string | null
          source_document_node_id?: string | null
          source_representation_id?: string | null
          supersedes_ids?: string[]
          tenant_id?: string
          vector_item_id?: string | null
          verification_state?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "packet_member_packet_restrict_fk"
            columns: ["tenant_id", "packet_id"]
            isOneToOne: false
            referencedRelation: "evidence_packet"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "packet_member_projection_fk"
            columns: ["tenant_id", "search_projection_id"]
            isOneToOne: false
            referencedRelation: "search_projection"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "packet_member_tenant_packet_fk"
            columns: ["tenant_id", "packet_id"]
            isOneToOne: false
            referencedRelation: "evidence_packet"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "packet_member_vector_item_fk"
            columns: ["tenant_id", "vector_item_id"]
            isOneToOne: false
            referencedRelation: "vector_item"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      projection_procedure: {
        Row: {
          chunking: Json
          code_ref: string | null
          container_sha256: string | null
          created_at: string
          description: string | null
          id: string
          implementation_sha256: string | null
          projection_policy: Json
          prompt_schema: Json
          slug: string
          template: string | null
          tokenizer: string | null
          version: number
        }
        Insert: {
          chunking?: Json
          code_ref?: string | null
          container_sha256?: string | null
          created_at?: string
          description?: string | null
          id?: string
          implementation_sha256?: string | null
          projection_policy?: Json
          prompt_schema?: Json
          slug: string
          template?: string | null
          tokenizer?: string | null
          version: number
        }
        Update: {
          chunking?: Json
          code_ref?: string | null
          container_sha256?: string | null
          created_at?: string
          description?: string | null
          id?: string
          implementation_sha256?: string | null
          projection_policy?: Json
          prompt_schema?: Json
          slug?: string
          template?: string | null
          tokenizer?: string | null
          version?: number
        }
        Relationships: []
      }
      projection_target: {
        Row: {
          admitted_at: string
          authored_revision_id: string | null
          chunk_id: string | null
          claim_id: string | null
          digest_id: string | null
          digest_item_id: string | null
          document_node_id: string | null
          entity_id: string | null
          id: string
          passage_id: string | null
          record_id: string | null
          retired_at: string | null
          summary_id: string | null
          target_kind: string
          tenant_id: string
        }
        Insert: {
          admitted_at?: string
          authored_revision_id?: string | null
          chunk_id?: string | null
          claim_id?: string | null
          digest_id?: string | null
          digest_item_id?: string | null
          document_node_id?: string | null
          entity_id?: string | null
          id?: string
          passage_id?: string | null
          record_id?: string | null
          retired_at?: string | null
          summary_id?: string | null
          target_kind: string
          tenant_id?: string
        }
        Update: {
          admitted_at?: string
          authored_revision_id?: string | null
          chunk_id?: string | null
          claim_id?: string | null
          digest_id?: string | null
          digest_item_id?: string | null
          document_node_id?: string | null
          entity_id?: string | null
          id?: string
          passage_id?: string | null
          record_id?: string | null
          retired_at?: string | null
          summary_id?: string | null
          target_kind?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "projection_target_chunk_id_fkey"
            columns: ["chunk_id"]
            isOneToOne: false
            referencedRelation: "retrieval_chunk"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "projection_target_tenant_id_chunk_id_fkey"
            columns: ["tenant_id", "chunk_id"]
            isOneToOne: false
            referencedRelation: "retrieval_chunk"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      publication_switch_receipt: {
        Row: {
          action: string
          actor_identity: string
          created_at: string
          from_publication_id: string | null
          guarded_sha256: string
          id: string
          idempotency_key: string
          reason: string
          tenant_id: string
          to_publication_id: string
          vector_store_space_id: string
        }
        Insert: {
          action: string
          actor_identity: string
          created_at?: string
          from_publication_id?: string | null
          guarded_sha256: string
          id?: string
          idempotency_key: string
          reason: string
          tenant_id?: string
          to_publication_id: string
          vector_store_space_id: string
        }
        Update: {
          action?: string
          actor_identity?: string
          created_at?: string
          from_publication_id?: string | null
          guarded_sha256?: string
          id?: string
          idempotency_key?: string
          reason?: string
          tenant_id?: string
          to_publication_id?: string
          vector_store_space_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "publication_switch_receipt_tenant_id_from_publication_id_fkey"
            columns: ["tenant_id", "from_publication_id"]
            isOneToOne: false
            referencedRelation: "space_publication"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "publication_switch_receipt_tenant_id_to_publication_id_fkey"
            columns: ["tenant_id", "to_publication_id"]
            isOneToOne: false
            referencedRelation: "space_publication"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "publication_switch_receipt_tenant_id_vector_store_space_id_fkey"
            columns: ["tenant_id", "vector_store_space_id"]
            isOneToOne: false
            referencedRelation: "vector_store_space"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      retrieval_candidate: {
        Row: {
          final_score: number | null
          id: string
          lexical_ref: string | null
          rank: number | null
          run_id: string
          stage_scores: Json
          tenant_id: string
          vector_item_id: string | null
        }
        Insert: {
          final_score?: number | null
          id?: string
          lexical_ref?: string | null
          rank?: number | null
          run_id: string
          stage_scores?: Json
          tenant_id?: string
          vector_item_id?: string | null
        }
        Update: {
          final_score?: number | null
          id?: string
          lexical_ref?: string | null
          rank?: number | null
          run_id?: string
          stage_scores?: Json
          tenant_id?: string
          vector_item_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "retrieval_candidate_run_id_fkey"
            columns: ["run_id"]
            isOneToOne: false
            referencedRelation: "retrieval_run"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "retrieval_candidate_tenant_run_fk"
            columns: ["tenant_id", "run_id"]
            isOneToOne: false
            referencedRelation: "retrieval_run"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "retrieval_candidate_vector_item_id_fkey"
            columns: ["vector_item_id"]
            isOneToOne: false
            referencedRelation: "vector_item"
            referencedColumns: ["id"]
          },
        ]
      }
      retrieval_candidate_source: {
        Row: {
          channel: string
          created_at: string
          explanation: Json
          id: string
          retrieval_candidate_id: string
          score: number
          search_projection_id: string | null
          source_rank: number
          tenant_id: string
          vector_item_id: string | null
        }
        Insert: {
          channel: string
          created_at?: string
          explanation?: Json
          id?: string
          retrieval_candidate_id: string
          score: number
          search_projection_id?: string | null
          source_rank: number
          tenant_id?: string
          vector_item_id?: string | null
        }
        Update: {
          channel?: string
          created_at?: string
          explanation?: Json
          id?: string
          retrieval_candidate_id?: string
          score?: number
          search_projection_id?: string | null
          source_rank?: number
          tenant_id?: string
          vector_item_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "retrieval_candidate_source_tenant_id_retrieval_candidate_i_fkey"
            columns: ["tenant_id", "retrieval_candidate_id"]
            isOneToOne: false
            referencedRelation: "retrieval_candidate"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "retrieval_candidate_source_tenant_id_search_projection_id_fkey"
            columns: ["tenant_id", "search_projection_id"]
            isOneToOne: false
            referencedRelation: "search_projection"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "retrieval_candidate_source_tenant_id_vector_item_id_fkey"
            columns: ["tenant_id", "vector_item_id"]
            isOneToOne: false
            referencedRelation: "vector_item"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      retrieval_chunk: {
        Row: {
          chunk_set_id: string
          contextual_prefix: string
          contextual_prefix_sha256: string
          created_at: string
          embedding_text: string
          embedding_text_sha256: string
          embedding_token_count: number
          id: string
          language: string | null
          lifecycle: string
          ordinal: number
          parent_chunk_id: string | null
          promotion_state: string
          retrieval_role: string
          source_text: string
          source_text_sha256: string
          source_token_count: number
          tenant_id: string
        }
        Insert: {
          chunk_set_id: string
          contextual_prefix?: string
          contextual_prefix_sha256: string
          created_at?: string
          embedding_text: string
          embedding_text_sha256: string
          embedding_token_count: number
          id?: string
          language?: string | null
          lifecycle?: string
          ordinal: number
          parent_chunk_id?: string | null
          promotion_state?: string
          retrieval_role: string
          source_text: string
          source_text_sha256: string
          source_token_count: number
          tenant_id?: string
        }
        Update: {
          chunk_set_id?: string
          contextual_prefix?: string
          contextual_prefix_sha256?: string
          created_at?: string
          embedding_text?: string
          embedding_text_sha256?: string
          embedding_token_count?: number
          id?: string
          language?: string | null
          lifecycle?: string
          ordinal?: number
          parent_chunk_id?: string | null
          promotion_state?: string
          retrieval_role?: string
          source_text?: string
          source_text_sha256?: string
          source_token_count?: number
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "retrieval_chunk_tenant_id_chunk_set_id_fkey"
            columns: ["tenant_id", "chunk_set_id"]
            isOneToOne: false
            referencedRelation: "chunk_set"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "retrieval_chunk_tenant_id_parent_chunk_id_fkey"
            columns: ["tenant_id", "parent_chunk_id"]
            isOneToOne: false
            referencedRelation: "retrieval_chunk"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      retrieval_plan: {
        Row: {
          created_at: string
          decomposition: Json
          filters: Json
          id: string
          policy_version: number
          proposed_by_attempt_id: string | null
          query_intent: string
          spaces: Json
          tenant_id: string
          validated: boolean
          validation_errors: Json | null
        }
        Insert: {
          created_at?: string
          decomposition?: Json
          filters?: Json
          id?: string
          policy_version?: number
          proposed_by_attempt_id?: string | null
          query_intent: string
          spaces?: Json
          tenant_id?: string
          validated?: boolean
          validation_errors?: Json | null
        }
        Update: {
          created_at?: string
          decomposition?: Json
          filters?: Json
          id?: string
          policy_version?: number
          proposed_by_attempt_id?: string | null
          query_intent?: string
          spaces?: Json
          tenant_id?: string
          validated?: boolean
          validation_errors?: Json | null
        }
        Relationships: []
      }
      retrieval_policy: {
        Row: {
          created_at: string
          id: string
          lifecycle: string
          purpose: string
          slug: string
          tenant_id: string
        }
        Insert: {
          created_at?: string
          id?: string
          lifecycle?: string
          purpose: string
          slug: string
          tenant_id?: string
        }
        Update: {
          created_at?: string
          id?: string
          lifecycle?: string
          purpose?: string
          slug?: string
          tenant_id?: string
        }
        Relationships: []
      }
      retrieval_policy_version: {
        Row: {
          created_at: string
          id: string
          policy: Json
          policy_schema: Json
          policy_sha256: string
          retrieval_policy_id: string
          status: string
          tenant_id: string
          version: number
        }
        Insert: {
          created_at?: string
          id?: string
          policy: Json
          policy_schema: Json
          policy_sha256: string
          retrieval_policy_id: string
          status?: string
          tenant_id?: string
          version: number
        }
        Update: {
          created_at?: string
          id?: string
          policy?: Json
          policy_schema?: Json
          policy_sha256?: string
          retrieval_policy_id?: string
          status?: string
          tenant_id?: string
          version?: number
        }
        Relationships: [
          {
            foreignKeyName: "retrieval_policy_version_tenant_id_retrieval_policy_id_fkey"
            columns: ["tenant_id", "retrieval_policy_id"]
            isOneToOne: false
            referencedRelation: "retrieval_policy"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      retrieval_run: {
        Row: {
          executed_at: string
          fusion_params: Json
          id: string
          operation_id: string | null
          plan_id: string
          request_sha256: string | null
          reranker_id: string | null
          stage_timings: Json
          tenant_id: string
        }
        Insert: {
          executed_at?: string
          fusion_params?: Json
          id?: string
          operation_id?: string | null
          plan_id: string
          request_sha256?: string | null
          reranker_id?: string | null
          stage_timings?: Json
          tenant_id?: string
        }
        Update: {
          executed_at?: string
          fusion_params?: Json
          id?: string
          operation_id?: string | null
          plan_id?: string
          request_sha256?: string | null
          reranker_id?: string | null
          stage_timings?: Json
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "retrieval_run_plan_id_fkey"
            columns: ["plan_id"]
            isOneToOne: false
            referencedRelation: "retrieval_plan"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "retrieval_run_tenant_plan_fk"
            columns: ["tenant_id", "plan_id"]
            isOneToOne: false
            referencedRelation: "retrieval_plan"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      search_projection: {
        Row: {
          classification: string
          content_kind: string
          content_promotion_decision_id: string | null
          contextual_prefix: string
          contextual_prefix_sha256: string
          created_at: string
          effective_during: unknown
          embedding_text: string
          embedding_text_sha256: string
          generator_identity: string | null
          id: string
          language: string | null
          projection_procedure_id: string
          projection_target_id: string
          promotion_state: string
          prompt_schema_version: string | null
          purpose: string
          representation_decision_id: string | null
          source_text: string
          source_text_sha256: string
          support_manifest: Json
          tenant_id: string
          visibility: string
        }
        Insert: {
          classification: string
          content_kind: string
          content_promotion_decision_id?: string | null
          contextual_prefix?: string
          contextual_prefix_sha256: string
          created_at?: string
          effective_during?: unknown
          embedding_text: string
          embedding_text_sha256: string
          generator_identity?: string | null
          id?: string
          language?: string | null
          projection_procedure_id: string
          projection_target_id: string
          promotion_state?: string
          prompt_schema_version?: string | null
          purpose: string
          representation_decision_id?: string | null
          source_text: string
          source_text_sha256: string
          support_manifest?: Json
          tenant_id?: string
          visibility: string
        }
        Update: {
          classification?: string
          content_kind?: string
          content_promotion_decision_id?: string | null
          contextual_prefix?: string
          contextual_prefix_sha256?: string
          created_at?: string
          effective_during?: unknown
          embedding_text?: string
          embedding_text_sha256?: string
          generator_identity?: string | null
          id?: string
          language?: string | null
          projection_procedure_id?: string
          projection_target_id?: string
          promotion_state?: string
          prompt_schema_version?: string | null
          purpose?: string
          representation_decision_id?: string | null
          source_text?: string
          source_text_sha256?: string
          support_manifest?: Json
          tenant_id?: string
          visibility?: string
        }
        Relationships: [
          {
            foreignKeyName: "search_projection_projection_procedure_id_fkey"
            columns: ["projection_procedure_id"]
            isOneToOne: false
            referencedRelation: "projection_procedure"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "search_projection_promotion_decision_fk"
            columns: ["tenant_id", "content_promotion_decision_id"]
            isOneToOne: false
            referencedRelation: "content_promotion_decision"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "search_projection_tenant_id_projection_target_id_fkey"
            columns: ["tenant_id", "projection_target_id"]
            isOneToOne: false
            referencedRelation: "projection_target"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      search_projection_chunk_support: {
        Row: {
          chunk_id: string
          created_at: string
          locator_id: string | null
          ordinal: number
          search_projection_id: string
          selected_text_sha256: string
          support_kind: string
          tenant_id: string
        }
        Insert: {
          chunk_id: string
          created_at?: string
          locator_id?: string | null
          ordinal: number
          search_projection_id: string
          selected_text_sha256: string
          support_kind: string
          tenant_id?: string
        }
        Update: {
          chunk_id?: string
          created_at?: string
          locator_id?: string | null
          ordinal?: number
          search_projection_id?: string
          selected_text_sha256?: string
          support_kind?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "search_projection_chunk_suppo_tenant_id_search_projection__fkey"
            columns: ["tenant_id", "search_projection_id"]
            isOneToOne: false
            referencedRelation: "search_projection"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "search_projection_chunk_support_tenant_id_chunk_id_fkey"
            columns: ["tenant_id", "chunk_id"]
            isOneToOne: false
            referencedRelation: "retrieval_chunk"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      space_publication: {
        Row: {
          created_at: string
          embedding_manifest_sha256: string
          evaluation_result_id: string | null
          expected_item_count: number
          id: string
          index_manifest_sha256: string
          legacy_provenance: boolean
          operation_id: string | null
          predecessor_id: string | null
          publication_decision_id: string
          published_at: string | null
          status: string
          tenant_id: string
          vector_item_manifest_sha256: string
          vector_space_version_id: string
          vector_store_space_id: string
        }
        Insert: {
          created_at?: string
          embedding_manifest_sha256: string
          evaluation_result_id?: string | null
          expected_item_count: number
          id?: string
          index_manifest_sha256: string
          legacy_provenance?: boolean
          operation_id?: string | null
          predecessor_id?: string | null
          publication_decision_id: string
          published_at?: string | null
          status?: string
          tenant_id?: string
          vector_item_manifest_sha256: string
          vector_space_version_id: string
          vector_store_space_id: string
        }
        Update: {
          created_at?: string
          embedding_manifest_sha256?: string
          evaluation_result_id?: string | null
          expected_item_count?: number
          id?: string
          index_manifest_sha256?: string
          legacy_provenance?: boolean
          operation_id?: string | null
          predecessor_id?: string | null
          publication_decision_id?: string
          published_at?: string | null
          status?: string
          tenant_id?: string
          vector_item_manifest_sha256?: string
          vector_space_version_id?: string
          vector_store_space_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "space_publication_tenant_id_predecessor_id_fkey"
            columns: ["tenant_id", "predecessor_id"]
            isOneToOne: false
            referencedRelation: "space_publication"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "space_publication_tenant_id_publication_decision_id_fkey"
            columns: ["tenant_id", "publication_decision_id"]
            isOneToOne: false
            referencedRelation: "content_promotion_decision"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "space_publication_tenant_id_vector_space_version_id_fkey"
            columns: ["tenant_id", "vector_space_version_id"]
            isOneToOne: false
            referencedRelation: "vector_space_version"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "space_publication_tenant_id_vector_store_space_id_fkey"
            columns: ["tenant_id", "vector_store_space_id"]
            isOneToOne: false
            referencedRelation: "vector_store_space"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      vector_item: {
        Row: {
          assurance_rank: number | null
          authority_level: string | null
          backend_location: string | null
          chunk_index: number
          classification: string | null
          content_kind: string
          content_sha256: string
          created_at: string
          document_id: string | null
          document_type_code: string | null
          document_version_id: string | null
          embedding_item_id: string | null
          end_ms: number | null
          entity_id: string | null
          entity_kind: string | null
          freshness_at: string | null
          generation_run_id: string | null
          id: string
          knowledge_seq: number | null
          language: string | null
          lens: string
          lifecycle: string
          observed_at: string | null
          projection_target_id: string | null
          receipt_id: string | null
          retrieval_chunk_id: string | null
          search_projection_id: string | null
          search_text: string | null
          search_tsv: unknown
          search_tsv_en: unknown
          secondary_entity_ids: string[]
          source_role_code: string | null
          source_tier: number | null
          source_version_hash: string | null
          space_version_id: string
          start_ms: number | null
          superseded_by_id: string | null
          tenant_id: string
          unit_kind: string | null
          valid_during: unknown
          verification_state: string
          visibility: string | null
          workspace_id: string | null
        }
        Insert: {
          assurance_rank?: number | null
          authority_level?: string | null
          backend_location?: string | null
          chunk_index?: number
          classification?: string | null
          content_kind?: string
          content_sha256: string
          created_at?: string
          document_id?: string | null
          document_type_code?: string | null
          document_version_id?: string | null
          embedding_item_id?: string | null
          end_ms?: number | null
          entity_id?: string | null
          entity_kind?: string | null
          freshness_at?: string | null
          generation_run_id?: string | null
          id?: string
          knowledge_seq?: number | null
          language?: string | null
          lens?: string
          lifecycle?: string
          observed_at?: string | null
          projection_target_id?: string | null
          receipt_id?: string | null
          retrieval_chunk_id?: string | null
          search_projection_id?: string | null
          search_text?: string | null
          search_tsv?: unknown
          search_tsv_en?: unknown
          secondary_entity_ids?: string[]
          source_role_code?: string | null
          source_tier?: number | null
          source_version_hash?: string | null
          space_version_id: string
          start_ms?: number | null
          superseded_by_id?: string | null
          tenant_id?: string
          unit_kind?: string | null
          valid_during?: unknown
          verification_state?: string
          visibility?: string | null
          workspace_id?: string | null
        }
        Update: {
          assurance_rank?: number | null
          authority_level?: string | null
          backend_location?: string | null
          chunk_index?: number
          classification?: string | null
          content_kind?: string
          content_sha256?: string
          created_at?: string
          document_id?: string | null
          document_type_code?: string | null
          document_version_id?: string | null
          embedding_item_id?: string | null
          end_ms?: number | null
          entity_id?: string | null
          entity_kind?: string | null
          freshness_at?: string | null
          generation_run_id?: string | null
          id?: string
          knowledge_seq?: number | null
          language?: string | null
          lens?: string
          lifecycle?: string
          observed_at?: string | null
          projection_target_id?: string | null
          receipt_id?: string | null
          retrieval_chunk_id?: string | null
          search_projection_id?: string | null
          search_text?: string | null
          search_tsv?: unknown
          search_tsv_en?: unknown
          secondary_entity_ids?: string[]
          source_role_code?: string | null
          source_tier?: number | null
          source_version_hash?: string | null
          space_version_id?: string
          start_ms?: number | null
          superseded_by_id?: string | null
          tenant_id?: string
          unit_kind?: string | null
          valid_during?: unknown
          verification_state?: string
          visibility?: string | null
          workspace_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "vector_item_embedding_item_fk"
            columns: ["tenant_id", "embedding_item_id"]
            isOneToOne: false
            referencedRelation: "embedding_item"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "vector_item_projection_fk"
            columns: ["tenant_id", "search_projection_id"]
            isOneToOne: false
            referencedRelation: "search_projection"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "vector_item_projection_target_id_fkey"
            columns: ["projection_target_id"]
            isOneToOne: false
            referencedRelation: "projection_target"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "vector_item_retrieval_chunk_fk"
            columns: ["tenant_id", "retrieval_chunk_id"]
            isOneToOne: false
            referencedRelation: "retrieval_chunk"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "vector_item_space_version_id_fkey"
            columns: ["space_version_id"]
            isOneToOne: false
            referencedRelation: "vector_space_version"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "vector_item_superseded_by_id_fkey"
            columns: ["superseded_by_id"]
            isOneToOne: false
            referencedRelation: "vector_item"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "vector_item_tenant_space_version_fk"
            columns: ["tenant_id", "space_version_id"]
            isOneToOne: false
            referencedRelation: "vector_space_version"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "vector_item_tenant_successor_fk"
            columns: ["tenant_id", "superseded_by_id"]
            isOneToOne: false
            referencedRelation: "vector_item"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      vector_item_embedding_1536: {
        Row: {
          created_at: string
          embedding: unknown
          embedding_sha256: string
          physical_embedding_sha256: string | null
          tenant_id: string
          vector_item_id: string
          vector_space_key: string
          vector_space_version_id: string
        }
        Insert: {
          created_at?: string
          embedding: unknown
          embedding_sha256: string
          physical_embedding_sha256?: string | null
          tenant_id: string
          vector_item_id: string
          vector_space_key: string
          vector_space_version_id: string
        }
        Update: {
          created_at?: string
          embedding?: unknown
          embedding_sha256?: string
          physical_embedding_sha256?: string | null
          tenant_id?: string
          vector_item_id?: string
          vector_space_key?: string
          vector_space_version_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "vector_item_embedding_1536_tenant_id_vector_item_id_fkey"
            columns: ["tenant_id", "vector_item_id"]
            isOneToOne: false
            referencedRelation: "vector_item"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "vector_item_embedding_1536_tenant_id_vector_space_version__fkey"
            columns: ["tenant_id", "vector_space_version_id"]
            isOneToOne: false
            referencedRelation: "vector_space_version"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      vector_item_embedding_1536_assertions: {
        Row: {
          created_at: string
          embedding: unknown
          embedding_sha256: string
          physical_embedding_sha256: string | null
          tenant_id: string
          vector_item_id: string
          vector_space_key: string
          vector_space_version_id: string
        }
        Insert: {
          created_at?: string
          embedding: unknown
          embedding_sha256: string
          physical_embedding_sha256?: string | null
          tenant_id: string
          vector_item_id: string
          vector_space_key: string
          vector_space_version_id: string
        }
        Update: {
          created_at?: string
          embedding?: unknown
          embedding_sha256?: string
          physical_embedding_sha256?: string | null
          tenant_id?: string
          vector_item_id?: string
          vector_space_key?: string
          vector_space_version_id?: string
        }
        Relationships: []
      }
      vector_item_embedding_1536_benchmark_intelligence: {
        Row: {
          created_at: string
          embedding: unknown
          embedding_sha256: string
          physical_embedding_sha256: string | null
          tenant_id: string
          vector_item_id: string
          vector_space_key: string
          vector_space_version_id: string
        }
        Insert: {
          created_at?: string
          embedding: unknown
          embedding_sha256: string
          physical_embedding_sha256?: string | null
          tenant_id: string
          vector_item_id: string
          vector_space_key: string
          vector_space_version_id: string
        }
        Update: {
          created_at?: string
          embedding?: unknown
          embedding_sha256?: string
          physical_embedding_sha256?: string | null
          tenant_id?: string
          vector_item_id?: string
          vector_space_key?: string
          vector_space_version_id?: string
        }
        Relationships: []
      }
      vector_item_embedding_1536_digests: {
        Row: {
          created_at: string
          embedding: unknown
          embedding_sha256: string
          physical_embedding_sha256: string | null
          tenant_id: string
          vector_item_id: string
          vector_space_key: string
          vector_space_version_id: string
        }
        Insert: {
          created_at?: string
          embedding: unknown
          embedding_sha256: string
          physical_embedding_sha256?: string | null
          tenant_id: string
          vector_item_id: string
          vector_space_key: string
          vector_space_version_id: string
        }
        Update: {
          created_at?: string
          embedding?: unknown
          embedding_sha256?: string
          physical_embedding_sha256?: string | null
          tenant_id?: string
          vector_item_id?: string
          vector_space_key?: string
          vector_space_version_id?: string
        }
        Relationships: []
      }
      vector_item_embedding_1536_document_summaries: {
        Row: {
          created_at: string
          embedding: unknown
          embedding_sha256: string
          physical_embedding_sha256: string | null
          tenant_id: string
          vector_item_id: string
          vector_space_key: string
          vector_space_version_id: string
        }
        Insert: {
          created_at?: string
          embedding: unknown
          embedding_sha256: string
          physical_embedding_sha256?: string | null
          tenant_id: string
          vector_item_id: string
          vector_space_key: string
          vector_space_version_id: string
        }
        Update: {
          created_at?: string
          embedding?: unknown
          embedding_sha256?: string
          physical_embedding_sha256?: string | null
          tenant_id?: string
          vector_item_id?: string
          vector_space_key?: string
          vector_space_version_id?: string
        }
        Relationships: []
      }
      vector_item_embedding_1536_engineering_claims: {
        Row: {
          created_at: string
          embedding: unknown
          embedding_sha256: string
          physical_embedding_sha256: string | null
          tenant_id: string
          vector_item_id: string
          vector_space_key: string
          vector_space_version_id: string
        }
        Insert: {
          created_at?: string
          embedding: unknown
          embedding_sha256: string
          physical_embedding_sha256?: string | null
          tenant_id: string
          vector_item_id: string
          vector_space_key: string
          vector_space_version_id: string
        }
        Update: {
          created_at?: string
          embedding?: unknown
          embedding_sha256?: string
          physical_embedding_sha256?: string | null
          tenant_id?: string
          vector_item_id?: string
          vector_space_key?: string
          vector_space_version_id?: string
        }
        Relationships: []
      }
      vector_item_embedding_1536_entity_cards: {
        Row: {
          created_at: string
          embedding: unknown
          embedding_sha256: string
          physical_embedding_sha256: string | null
          tenant_id: string
          vector_item_id: string
          vector_space_key: string
          vector_space_version_id: string
        }
        Insert: {
          created_at?: string
          embedding: unknown
          embedding_sha256: string
          physical_embedding_sha256?: string | null
          tenant_id: string
          vector_item_id: string
          vector_space_key: string
          vector_space_version_id: string
        }
        Update: {
          created_at?: string
          embedding?: unknown
          embedding_sha256?: string
          physical_embedding_sha256?: string | null
          tenant_id?: string
          vector_item_id?: string
          vector_space_key?: string
          vector_space_version_id?: string
        }
        Relationships: []
      }
      vector_item_embedding_1536_entity_profiles: {
        Row: {
          created_at: string
          embedding: unknown
          embedding_sha256: string
          physical_embedding_sha256: string | null
          tenant_id: string
          vector_item_id: string
          vector_space_key: string
          vector_space_version_id: string
        }
        Insert: {
          created_at?: string
          embedding: unknown
          embedding_sha256: string
          physical_embedding_sha256?: string | null
          tenant_id: string
          vector_item_id: string
          vector_space_key: string
          vector_space_version_id: string
        }
        Update: {
          created_at?: string
          embedding?: unknown
          embedding_sha256?: string
          physical_embedding_sha256?: string | null
          tenant_id?: string
          vector_item_id?: string
          vector_space_key?: string
          vector_space_version_id?: string
        }
        Relationships: []
      }
      vector_item_embedding_1536_entity_timeline: {
        Row: {
          created_at: string
          embedding: unknown
          embedding_sha256: string
          physical_embedding_sha256: string | null
          tenant_id: string
          vector_item_id: string
          vector_space_key: string
          vector_space_version_id: string
        }
        Insert: {
          created_at?: string
          embedding: unknown
          embedding_sha256: string
          physical_embedding_sha256?: string | null
          tenant_id: string
          vector_item_id: string
          vector_space_key: string
          vector_space_version_id: string
        }
        Update: {
          created_at?: string
          embedding?: unknown
          embedding_sha256?: string
          physical_embedding_sha256?: string | null
          tenant_id?: string
          vector_item_id?: string
          vector_space_key?: string
          vector_space_version_id?: string
        }
        Relationships: []
      }
      vector_item_embedding_1536_implementation_examples: {
        Row: {
          created_at: string
          embedding: unknown
          embedding_sha256: string
          physical_embedding_sha256: string | null
          tenant_id: string
          vector_item_id: string
          vector_space_key: string
          vector_space_version_id: string
        }
        Insert: {
          created_at?: string
          embedding: unknown
          embedding_sha256: string
          physical_embedding_sha256?: string | null
          tenant_id: string
          vector_item_id: string
          vector_space_key: string
          vector_space_version_id: string
        }
        Update: {
          created_at?: string
          embedding?: unknown
          embedding_sha256?: string
          physical_embedding_sha256?: string | null
          tenant_id?: string
          vector_item_id?: string
          vector_space_key?: string
          vector_space_version_id?: string
        }
        Relationships: []
      }
      vector_item_embedding_1536_knowledge_text: {
        Row: {
          created_at: string
          embedding: unknown
          embedding_sha256: string
          physical_embedding_sha256: string | null
          tenant_id: string
          vector_item_id: string
          vector_space_key: string
          vector_space_version_id: string
        }
        Insert: {
          created_at?: string
          embedding: unknown
          embedding_sha256: string
          physical_embedding_sha256?: string | null
          tenant_id: string
          vector_item_id: string
          vector_space_key: string
          vector_space_version_id: string
        }
        Update: {
          created_at?: string
          embedding?: unknown
          embedding_sha256?: string
          physical_embedding_sha256?: string | null
          tenant_id?: string
          vector_item_id?: string
          vector_space_key?: string
          vector_space_version_id?: string
        }
        Relationships: []
      }
      vector_item_embedding_1536_learner_notes: {
        Row: {
          created_at: string
          embedding: unknown
          embedding_sha256: string
          physical_embedding_sha256: string | null
          tenant_id: string
          vector_item_id: string
          vector_space_key: string
          vector_space_version_id: string
        }
        Insert: {
          created_at?: string
          embedding: unknown
          embedding_sha256: string
          physical_embedding_sha256?: string | null
          tenant_id: string
          vector_item_id: string
          vector_space_key: string
          vector_space_version_id: string
        }
        Update: {
          created_at?: string
          embedding?: unknown
          embedding_sha256?: string
          physical_embedding_sha256?: string | null
          tenant_id?: string
          vector_item_id?: string
          vector_space_key?: string
          vector_space_version_id?: string
        }
        Relationships: []
      }
      vector_item_embedding_1536_market_intelligence: {
        Row: {
          created_at: string
          embedding: unknown
          embedding_sha256: string
          physical_embedding_sha256: string | null
          tenant_id: string
          vector_item_id: string
          vector_space_key: string
          vector_space_version_id: string
        }
        Insert: {
          created_at?: string
          embedding: unknown
          embedding_sha256: string
          physical_embedding_sha256?: string | null
          tenant_id: string
          vector_item_id: string
          vector_space_key: string
          vector_space_version_id: string
        }
        Update: {
          created_at?: string
          embedding?: unknown
          embedding_sha256?: string
          physical_embedding_sha256?: string | null
          tenant_id?: string
          vector_item_id?: string
          vector_space_key?: string
          vector_space_version_id?: string
        }
        Relationships: []
      }
      vector_item_embedding_1536_model_capabilities: {
        Row: {
          created_at: string
          embedding: unknown
          embedding_sha256: string
          physical_embedding_sha256: string | null
          tenant_id: string
          vector_item_id: string
          vector_space_key: string
          vector_space_version_id: string
        }
        Insert: {
          created_at?: string
          embedding: unknown
          embedding_sha256: string
          physical_embedding_sha256?: string | null
          tenant_id: string
          vector_item_id: string
          vector_space_key: string
          vector_space_version_id: string
        }
        Update: {
          created_at?: string
          embedding?: unknown
          embedding_sha256?: string
          physical_embedding_sha256?: string | null
          tenant_id?: string
          vector_item_id?: string
          vector_space_key?: string
          vector_space_version_id?: string
        }
        Relationships: []
      }
      vector_item_embedding_1536_own_content: {
        Row: {
          created_at: string
          embedding: unknown
          embedding_sha256: string
          physical_embedding_sha256: string | null
          tenant_id: string
          vector_item_id: string
          vector_space_key: string
          vector_space_version_id: string
        }
        Insert: {
          created_at?: string
          embedding: unknown
          embedding_sha256: string
          physical_embedding_sha256?: string | null
          tenant_id: string
          vector_item_id: string
          vector_space_key: string
          vector_space_version_id: string
        }
        Update: {
          created_at?: string
          embedding?: unknown
          embedding_sha256?: string
          physical_embedding_sha256?: string | null
          tenant_id?: string
          vector_item_id?: string
          vector_space_key?: string
          vector_space_version_id?: string
        }
        Relationships: []
      }
      vector_item_embedding_1536_paper_case_study_knowledge: {
        Row: {
          created_at: string
          embedding: unknown
          embedding_sha256: string
          physical_embedding_sha256: string | null
          tenant_id: string
          vector_item_id: string
          vector_space_key: string
          vector_space_version_id: string
        }
        Insert: {
          created_at?: string
          embedding: unknown
          embedding_sha256: string
          physical_embedding_sha256?: string | null
          tenant_id: string
          vector_item_id: string
          vector_space_key: string
          vector_space_version_id: string
        }
        Update: {
          created_at?: string
          embedding?: unknown
          embedding_sha256?: string
          physical_embedding_sha256?: string | null
          tenant_id?: string
          vector_item_id?: string
          vector_space_key?: string
          vector_space_version_id?: string
        }
        Relationships: []
      }
      vector_item_embedding_1536_source_native_sections: {
        Row: {
          created_at: string
          embedding: unknown
          embedding_sha256: string
          physical_embedding_sha256: string | null
          tenant_id: string
          vector_item_id: string
          vector_space_key: string
          vector_space_version_id: string
        }
        Insert: {
          created_at?: string
          embedding: unknown
          embedding_sha256: string
          physical_embedding_sha256?: string | null
          tenant_id: string
          vector_item_id: string
          vector_space_key: string
          vector_space_version_id: string
        }
        Update: {
          created_at?: string
          embedding?: unknown
          embedding_sha256?: string
          physical_embedding_sha256?: string | null
          tenant_id?: string
          vector_item_id?: string
          vector_space_key?: string
          vector_space_version_id?: string
        }
        Relationships: []
      }
      vector_item_embedding_1536_tool_capabilities: {
        Row: {
          created_at: string
          embedding: unknown
          embedding_sha256: string
          physical_embedding_sha256: string | null
          tenant_id: string
          vector_item_id: string
          vector_space_key: string
          vector_space_version_id: string
        }
        Insert: {
          created_at?: string
          embedding: unknown
          embedding_sha256: string
          physical_embedding_sha256?: string | null
          tenant_id: string
          vector_item_id: string
          vector_space_key: string
          vector_space_version_id: string
        }
        Update: {
          created_at?: string
          embedding?: unknown
          embedding_sha256?: string
          physical_embedding_sha256?: string | null
          tenant_id?: string
          vector_item_id?: string
          vector_space_key?: string
          vector_space_version_id?: string
        }
        Relationships: []
      }
      vector_item_embedding_1536_units: {
        Row: {
          created_at: string
          embedding: unknown
          embedding_sha256: string
          physical_embedding_sha256: string | null
          tenant_id: string
          vector_item_id: string
          vector_space_key: string
          vector_space_version_id: string
        }
        Insert: {
          created_at?: string
          embedding: unknown
          embedding_sha256: string
          physical_embedding_sha256?: string | null
          tenant_id: string
          vector_item_id: string
          vector_space_key: string
          vector_space_version_id: string
        }
        Update: {
          created_at?: string
          embedding?: unknown
          embedding_sha256?: string
          physical_embedding_sha256?: string | null
          tenant_id?: string
          vector_item_id?: string
          vector_space_key?: string
          vector_space_version_id?: string
        }
        Relationships: []
      }
      vector_space: {
        Row: {
          class: Database["retrieval"]["Enums"]["space_class"]
          created_at: string
          id: string
          purpose: string
          slug: string
          tenant_id: string
        }
        Insert: {
          class?: Database["retrieval"]["Enums"]["space_class"]
          created_at?: string
          id?: string
          purpose: string
          slug: string
          tenant_id?: string
        }
        Update: {
          class?: Database["retrieval"]["Enums"]["space_class"]
          created_at?: string
          id?: string
          purpose?: string
          slug?: string
          tenant_id?: string
        }
        Relationships: []
      }
      vector_space_version: {
        Row: {
          backend: Database["retrieval"]["Enums"]["backend_kind"]
          created_at: string
          dims: number
          distance_operator: string
          embedding_model: string
          id: string
          index_configuration: Json
          normalization: string
          precision: string
          projection_procedure_id: string | null
          promoted: boolean
          promotion_gate_eval_id: string | null
          provider_routing_policy: Json
          publication_decision_id: string | null
          publication_lifecycle: string
          tenant_id: string
          vector_space_id: string
          version: number
        }
        Insert: {
          backend: Database["retrieval"]["Enums"]["backend_kind"]
          created_at?: string
          dims: number
          distance_operator?: string
          embedding_model: string
          id?: string
          index_configuration?: Json
          normalization?: string
          precision?: string
          projection_procedure_id?: string | null
          promoted?: boolean
          promotion_gate_eval_id?: string | null
          provider_routing_policy?: Json
          publication_decision_id?: string | null
          publication_lifecycle?: string
          tenant_id?: string
          vector_space_id: string
          version: number
        }
        Update: {
          backend?: Database["retrieval"]["Enums"]["backend_kind"]
          created_at?: string
          dims?: number
          distance_operator?: string
          embedding_model?: string
          id?: string
          index_configuration?: Json
          normalization?: string
          precision?: string
          projection_procedure_id?: string | null
          promoted?: boolean
          promotion_gate_eval_id?: string | null
          provider_routing_policy?: Json
          publication_decision_id?: string | null
          publication_lifecycle?: string
          tenant_id?: string
          vector_space_id?: string
          version?: number
        }
        Relationships: [
          {
            foreignKeyName: "vector_space_version_projection_procedure_id_fkey"
            columns: ["projection_procedure_id"]
            isOneToOne: false
            referencedRelation: "projection_procedure"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "vector_space_version_tenant_space_fk"
            columns: ["tenant_id", "vector_space_id"]
            isOneToOne: false
            referencedRelation: "vector_space"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "vector_space_version_vector_space_id_fkey"
            columns: ["vector_space_id"]
            isOneToOne: false
            referencedRelation: "vector_space"
            referencedColumns: ["id"]
          },
        ]
      }
      vector_store: {
        Row: {
          created_at: string
          created_by_attempt_id: string | null
          created_by_operation_id: string | null
          deletion_policy: Json
          id: string
          lifecycle: string
          name: string
          owner_identity: string
          purpose: string
          quota_profile: Json
          retention_policy: Json
          slug: string
          store_class: string
          supersedes_id: string | null
          tenant_id: string
          visibility: string
        }
        Insert: {
          created_at?: string
          created_by_attempt_id?: string | null
          created_by_operation_id?: string | null
          deletion_policy?: Json
          id?: string
          lifecycle?: string
          name: string
          owner_identity: string
          purpose: string
          quota_profile?: Json
          retention_policy?: Json
          slug: string
          store_class: string
          supersedes_id?: string | null
          tenant_id?: string
          visibility: string
        }
        Update: {
          created_at?: string
          created_by_attempt_id?: string | null
          created_by_operation_id?: string | null
          deletion_policy?: Json
          id?: string
          lifecycle?: string
          name?: string
          owner_identity?: string
          purpose?: string
          quota_profile?: Json
          retention_policy?: Json
          slug?: string
          store_class?: string
          supersedes_id?: string | null
          tenant_id?: string
          visibility?: string
        }
        Relationships: [
          {
            foreignKeyName: "vector_store_tenant_id_supersedes_id_fkey"
            columns: ["tenant_id", "supersedes_id"]
            isOneToOne: false
            referencedRelation: "vector_store"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      vector_store_document: {
        Row: {
          admission_state: string
          created_at: string
          created_by_operation_id: string | null
          document_id: string
          document_version_id: string | null
          id: string
          lifecycle: string
          representation_id: string | null
          requested_profile: Json
          supersedes_id: string | null
          tenant_id: string
          tombstone_receipt_id: string | null
          vector_store_id: string
        }
        Insert: {
          admission_state?: string
          created_at?: string
          created_by_operation_id?: string | null
          document_id: string
          document_version_id?: string | null
          id?: string
          lifecycle?: string
          representation_id?: string | null
          requested_profile?: Json
          supersedes_id?: string | null
          tenant_id?: string
          tombstone_receipt_id?: string | null
          vector_store_id: string
        }
        Update: {
          admission_state?: string
          created_at?: string
          created_by_operation_id?: string | null
          document_id?: string
          document_version_id?: string | null
          id?: string
          lifecycle?: string
          representation_id?: string | null
          requested_profile?: Json
          supersedes_id?: string | null
          tenant_id?: string
          tombstone_receipt_id?: string | null
          vector_store_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "vector_store_document_tenant_id_supersedes_id_fkey"
            columns: ["tenant_id", "supersedes_id"]
            isOneToOne: false
            referencedRelation: "vector_store_document"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "vector_store_document_tenant_id_vector_store_id_fkey"
            columns: ["tenant_id", "vector_store_id"]
            isOneToOne: false
            referencedRelation: "vector_store"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      vector_store_ingestion_checkpoint: {
        Row: {
          created_at: string
          evidence: Json
          evidence_sha256: string
          id: string
          ingestion_run_id: string
          stage: string
          tenant_id: string
        }
        Insert: {
          created_at?: string
          evidence: Json
          evidence_sha256: string
          id?: string
          ingestion_run_id: string
          stage: string
          tenant_id?: string
        }
        Update: {
          created_at?: string
          evidence?: Json
          evidence_sha256?: string
          id?: string
          ingestion_run_id?: string
          stage?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "vector_store_ingestion_checkpoi_tenant_id_ingestion_run_id_fkey"
            columns: ["tenant_id", "ingestion_run_id"]
            isOneToOne: false
            referencedRelation: "vector_store_ingestion_run"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      vector_store_ingestion_run: {
        Row: {
          actor_identity: string
          created_at: string
          id: string
          manifest: Json
          operation_id: string
          request_sha256: string
          tenant_id: string
          vector_store_id: string
        }
        Insert: {
          actor_identity: string
          created_at?: string
          id?: string
          manifest: Json
          operation_id: string
          request_sha256: string
          tenant_id?: string
          vector_store_id: string
        }
        Update: {
          actor_identity?: string
          created_at?: string
          id?: string
          manifest?: Json
          operation_id?: string
          request_sha256?: string
          tenant_id?: string
          vector_store_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "vector_store_ingestion_run_tenant_id_vector_store_id_fkey"
            columns: ["tenant_id", "vector_store_id"]
            isOneToOne: false
            referencedRelation: "vector_store"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      vector_store_lifecycle_event: {
        Row: {
          actor_identity: string
          id: string
          new_lifecycle: string
          occurred_at: string
          previous_lifecycle: string
          reason: string
          tenant_id: string
          vector_store_id: string
        }
        Insert: {
          actor_identity: string
          id?: string
          new_lifecycle: string
          occurred_at?: string
          previous_lifecycle: string
          reason: string
          tenant_id?: string
          vector_store_id: string
        }
        Update: {
          actor_identity?: string
          id?: string
          new_lifecycle?: string
          occurred_at?: string
          previous_lifecycle?: string
          reason?: string
          tenant_id?: string
          vector_store_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "vector_store_lifecycle_event_tenant_id_vector_store_id_fkey"
            columns: ["tenant_id", "vector_store_id"]
            isOneToOne: false
            referencedRelation: "vector_store"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      vector_store_space: {
        Row: {
          active_space_version_id: string | null
          authority_class: string
          created_at: string
          id: string
          tenant_id: string
          vector_space_id: string
          vector_store_id: string
        }
        Insert: {
          active_space_version_id?: string | null
          authority_class: string
          created_at?: string
          id?: string
          tenant_id?: string
          vector_space_id: string
          vector_store_id: string
        }
        Update: {
          active_space_version_id?: string | null
          authority_class?: string
          created_at?: string
          id?: string
          tenant_id?: string
          vector_space_id?: string
          vector_store_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "vector_store_space_tenant_id_active_space_version_id_fkey"
            columns: ["tenant_id", "active_space_version_id"]
            isOneToOne: false
            referencedRelation: "vector_space_version"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "vector_store_space_tenant_id_vector_space_id_fkey"
            columns: ["tenant_id", "vector_space_id"]
            isOneToOne: false
            referencedRelation: "vector_space"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "vector_store_space_tenant_id_vector_store_id_fkey"
            columns: ["tenant_id", "vector_store_id"]
            isOneToOne: false
            referencedRelation: "vector_store"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      claim_history_witnesses: {
        Args: { p_claim: string; p_k: number }
        Returns: {
          claim_id: string
          entity_ids: string[]
          event_occurrence_id: string
          k_from: number
          k_to: number
          segment_id: string
          support_id: string
          world_interval: unknown
        }[]
      }
      evidence_signal: {
        Args: { p_claim: string; p_document: string; p_unit_kind: string }
        Returns: Json
      }
      history_claim_authorized: { Args: { p_claim: string }; Returns: boolean }
      history_projection_matches: {
        Args: {
          p_at: string
          p_entities: string[]
          p_from: string
          p_k: number
          p_projection: string
          p_to: string
        }
        Returns: boolean
      }
      history_publication_authorized: {
        Args: { p_publication: string; p_version: string }
        Returns: string
      }
      history_receipt_k: { Args: { p_receipt: string }; Returns: number }
      history_representation_authorized: {
        Args: { p_representation: string }
        Returns: boolean
      }
      history_world_matches: {
        Args: {
          p_at: string
          p_from: string
          p_interval: unknown
          p_to: string
        }
        Returns: boolean
      }
      index_text_item: {
        Args: {
          p_assurance_rank?: number
          p_content_kind: string
          p_contextual_prefix?: string
          p_document_id?: string
          p_document_type_code?: string
          p_document_version_id?: string
          p_end_ms?: number
          p_entity_id?: string
          p_knowledge_seq?: number
          p_language?: string
          p_lens: string
          p_observed_at?: string
          p_secondary_entity_ids?: string[]
          p_source_role_code?: string
          p_source_tier: number
          p_space_slug: string
          p_start_ms?: number
          p_target_id: string
          p_target_kind: string
          p_text: string
          p_unit_kind?: string
          p_valid_during?: unknown
          p_workspace_id?: string
        }
        Returns: string
      }
      project_entity_timeline: { Args: { p_k?: number }; Returns: number }
      promote_release_passages: { Args: { p_release: string }; Returns: number }
      promote_revision_passages: {
        Args: { p_revision: string }
        Returns: number
      }
      publish_vector_space: {
        Args: {
          p_actor_identity: string
          p_expected_guarded_sha256: string
          p_idempotency_key: string
          p_publication_id: string
          p_reason: string
        }
        Returns: string
      }
      retire_deterministic_digest_items: { Args: never; Returns: number }
      retire_items_for_passages: {
        Args: { p_passage_ids: string[] }
        Returns: number
      }
      rollback_vector_space: {
        Args: {
          p_actor_identity: string
          p_current_publication_id: string
          p_expected_guarded_sha256: string
          p_idempotency_key: string
          p_operation_id: string
          p_reason: string
          p_target_publication_id: string
        }
        Returns: string
      }
      store_embedding: {
        Args: {
          p_embedding: unknown
          p_embedding_sha256: string
          p_vector_item: string
        }
        Returns: undefined
      }
      supersede_duplicate_items: { Args: never; Returns: number }
      transition_vector_store_lifecycle: {
        Args: {
          p_actor_identity: string
          p_reason: string
          p_successor_id?: string
          p_target_lifecycle: string
          p_vector_store_id: string
        }
        Returns: string
      }
      validate_chunk_projection_target: {
        Args: { p_chunk_id: string; p_tenant_id: string }
        Returns: boolean
      }
    }
    Enums: {
      backend_kind: "vector_bucket" | "pgvector"
      space_class: "canonical" | "exploratory"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  staging: {
    Tables: {
      candidate: {
        Row: {
          created_at: string
          id: string
          proposed_kind: string
          proposed_payload: Json
          resolved_entity_id: string | null
          source_id: string | null
          tenant_id: string
        }
        Insert: {
          created_at?: string
          id?: string
          proposed_kind: string
          proposed_payload: Json
          resolved_entity_id?: string | null
          source_id?: string | null
          tenant_id?: string
        }
        Update: {
          created_at?: string
          id?: string
          proposed_kind?: string
          proposed_payload?: Json
          resolved_entity_id?: string | null
          source_id?: string | null
          tenant_id?: string
        }
        Relationships: []
      }
      identity_match: {
        Row: {
          candidate_id: string
          confidence: number
          entity_id: string
          id: string
          method: string
          tenant_id: string
        }
        Insert: {
          candidate_id: string
          confidence: number
          entity_id: string
          id?: string
          method: string
          tenant_id?: string
        }
        Update: {
          candidate_id?: string
          confidence?: number
          entity_id?: string
          id?: string
          method?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "identity_match_candidate_id_fkey"
            columns: ["candidate_id"]
            isOneToOne: false
            referencedRelation: "candidate"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "identity_match_tenant_id_candidate_id_fkey"
            columns: ["tenant_id", "candidate_id"]
            isOneToOne: false
            referencedRelation: "candidate"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      resolution_decision: {
        Row: {
          candidate_id: string
          created_at: string
          decision: string
          entity_id: string | null
          id: string
          receipt_id: string
          tenant_id: string
        }
        Insert: {
          candidate_id: string
          created_at?: string
          decision: string
          entity_id?: string | null
          id?: string
          receipt_id: string
          tenant_id?: string
        }
        Update: {
          candidate_id?: string
          created_at?: string
          decision?: string
          entity_id?: string | null
          id?: string
          receipt_id?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "resolution_decision_candidate_id_fkey"
            columns: ["candidate_id"]
            isOneToOne: false
            referencedRelation: "candidate"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "resolution_decision_tenant_id_candidate_id_fkey"
            columns: ["tenant_id", "candidate_id"]
            isOneToOne: false
            referencedRelation: "candidate"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      vetting_decision: {
        Row: {
          candidate_id: string
          created_at: string
          decision: string
          id: string
          reason: string
          receipt_id: string
          tenant_id: string
        }
        Insert: {
          candidate_id: string
          created_at?: string
          decision: string
          id?: string
          reason: string
          receipt_id: string
          tenant_id?: string
        }
        Update: {
          candidate_id?: string
          created_at?: string
          decision?: string
          id?: string
          reason?: string
          receipt_id?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "vetting_decision_candidate_id_fkey"
            columns: ["candidate_id"]
            isOneToOne: false
            referencedRelation: "candidate"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "vetting_decision_tenant_id_candidate_id_fkey"
            columns: ["tenant_id", "candidate_id"]
            isOneToOne: false
            referencedRelation: "candidate"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      candidate_status:
        | "discovered"
        | "enriched"
        | "matched"
        | "resolved"
        | "promoted"
        | "quarantined"
        | "rejected"
      resolution_outcome:
        | "insert"
        | "update"
        | "link"
        | "merge"
        | "supersede"
        | "no_op"
        | "quarantine"
        | "reject"
        | "review"
      vetting_outcome:
        | "approved_for_metrics"
        | "approved_for_research"
        | "approved_provisionally"
        | "deferred"
        | "insufficient_evidence"
        | "out_of_scope"
        | "rejected"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  taxonomy: {
    Tables: {
      assignment: {
        Row: {
          confidence: number | null
          created_at: string
          created_by_receipt_id: string | null
          id: string
          method: string
          provenance_claim_id: string | null
          review_task_id: string | null
          target_entity_id: string | null
          target_record_id: string | null
          target_work_id: string | null
          tenant_id: string
          term_id: string
          valid_from: string
          valid_to: string | null
        }
        Insert: {
          confidence?: number | null
          created_at?: string
          created_by_receipt_id?: string | null
          id?: string
          method: string
          provenance_claim_id?: string | null
          review_task_id?: string | null
          target_entity_id?: string | null
          target_record_id?: string | null
          target_work_id?: string | null
          tenant_id?: string
          term_id: string
          valid_from?: string
          valid_to?: string | null
        }
        Update: {
          confidence?: number | null
          created_at?: string
          created_by_receipt_id?: string | null
          id?: string
          method?: string
          provenance_claim_id?: string | null
          review_task_id?: string | null
          target_entity_id?: string | null
          target_record_id?: string | null
          target_work_id?: string | null
          tenant_id?: string
          term_id?: string
          valid_from?: string
          valid_to?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "assignment_term_id_fkey"
            columns: ["term_id"]
            isOneToOne: false
            referencedRelation: "term"
            referencedColumns: ["id"]
          },
        ]
      }
      assignment_review_requirement: {
        Row: {
          created_at: string
          facet_id: string
          requires_review: boolean
          rule: Json
        }
        Insert: {
          created_at?: string
          facet_id: string
          requires_review?: boolean
          rule?: Json
        }
        Update: {
          created_at?: string
          facet_id?: string
          requires_review?: boolean
          rule?: Json
        }
        Relationships: [
          {
            foreignKeyName: "assignment_review_requirement_facet_id_fkey"
            columns: ["facet_id"]
            isOneToOne: true
            referencedRelation: "facet"
            referencedColumns: ["id"]
          },
        ]
      }
      entity_kind: {
        Row: {
          attributes_schema: Json
          canonical_schema: string
          canonical_table: string
          code: string
          description: string
          is_work: boolean
          label: string
          lens: string
          parent_kind: string | null
        }
        Insert: {
          attributes_schema?: Json
          canonical_schema?: string
          canonical_table?: string
          code: string
          description: string
          is_work?: boolean
          label?: string
          lens?: string
          parent_kind?: string | null
        }
        Update: {
          attributes_schema?: Json
          canonical_schema?: string
          canonical_table?: string
          code?: string
          description?: string
          is_work?: boolean
          label?: string
          lens?: string
          parent_kind?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "entity_kind_parent_kind_fkey"
            columns: ["parent_kind"]
            isOneToOne: false
            referencedRelation: "entity_kind"
            referencedColumns: ["code"]
          },
        ]
      }
      facet: {
        Row: {
          cardinality: string
          created_at: string
          description: string | null
          id: string
          label: string
          slug: string
          tenant_id: string
          updated_at: string
        }
        Insert: {
          cardinality?: string
          created_at?: string
          description?: string | null
          id?: string
          label: string
          slug: string
          tenant_id?: string
          updated_at?: string
        }
        Update: {
          cardinality?: string
          created_at?: string
          description?: string | null
          id?: string
          label?: string
          slug?: string
          tenant_id?: string
          updated_at?: string
        }
        Relationships: []
      }
      facet_version: {
        Row: {
          approved_at: string | null
          approved_by_review_task_id: string | null
          created_at: string
          facet_id: string
          id: string
          notes: string | null
          status: Database["taxonomy"]["Enums"]["facet_status"]
          version: number
        }
        Insert: {
          approved_at?: string | null
          approved_by_review_task_id?: string | null
          created_at?: string
          facet_id: string
          id?: string
          notes?: string | null
          status?: Database["taxonomy"]["Enums"]["facet_status"]
          version: number
        }
        Update: {
          approved_at?: string | null
          approved_by_review_task_id?: string | null
          created_at?: string
          facet_id?: string
          id?: string
          notes?: string | null
          status?: Database["taxonomy"]["Enums"]["facet_status"]
          version?: number
        }
        Relationships: [
          {
            foreignKeyName: "facet_version_facet_id_fkey"
            columns: ["facet_id"]
            isOneToOne: false
            referencedRelation: "facet"
            referencedColumns: ["id"]
          },
        ]
      }
      relationship_kind: {
        Row: {
          code: string
          description: string
          from_kinds: string[]
          inverse_label: string | null
          property_schema: Json
          symmetric: boolean
          temporal: boolean
          to_kinds: string[]
        }
        Insert: {
          code: string
          description: string
          from_kinds: string[]
          inverse_label?: string | null
          property_schema?: Json
          symmetric?: boolean
          temporal: boolean
          to_kinds: string[]
        }
        Update: {
          code?: string
          description?: string
          from_kinds?: string[]
          inverse_label?: string | null
          property_schema?: Json
          symmetric?: boolean
          temporal?: boolean
          to_kinds?: string[]
        }
        Relationships: []
      }
      term: {
        Row: {
          created_at: string
          definition: string | null
          facet_version_id: string
          id: string
          label: string
          parent_term_id: string | null
          slug: string
          sort_order: number
        }
        Insert: {
          created_at?: string
          definition?: string | null
          facet_version_id: string
          id?: string
          label: string
          parent_term_id?: string | null
          slug: string
          sort_order?: number
        }
        Update: {
          created_at?: string
          definition?: string | null
          facet_version_id?: string
          id?: string
          label?: string
          parent_term_id?: string | null
          slug?: string
          sort_order?: number
        }
        Relationships: [
          {
            foreignKeyName: "term_facet_version_id_fkey"
            columns: ["facet_version_id"]
            isOneToOne: false
            referencedRelation: "facet_version"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "term_parent_term_id_fkey"
            columns: ["parent_term_id"]
            isOneToOne: false
            referencedRelation: "term"
            referencedColumns: ["id"]
          },
        ]
      }
      term_relation: {
        Row: {
          created_at: string
          from_term_id: string
          relation_kind: string
          to_term_id: string
        }
        Insert: {
          created_at?: string
          from_term_id: string
          relation_kind: string
          to_term_id: string
        }
        Update: {
          created_at?: string
          from_term_id?: string
          relation_kind?: string
          to_term_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "term_relation_from_term_id_fkey"
            columns: ["from_term_id"]
            isOneToOne: false
            referencedRelation: "term"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "term_relation_to_term_id_fkey"
            columns: ["to_term_id"]
            isOneToOne: false
            referencedRelation: "term"
            referencedColumns: ["id"]
          },
        ]
      }
      term_target_kind: {
        Row: {
          created_at: string
          entity_kind_code: string
          term_id: string
        }
        Insert: {
          created_at?: string
          entity_kind_code: string
          term_id: string
        }
        Update: {
          created_at?: string
          entity_kind_code?: string
          term_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "term_target_kind_entity_kind_code_fkey"
            columns: ["entity_kind_code"]
            isOneToOne: false
            referencedRelation: "entity_kind"
            referencedColumns: ["code"]
          },
          {
            foreignKeyName: "term_target_kind_term_id_fkey"
            columns: ["term_id"]
            isOneToOne: false
            referencedRelation: "term"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      facet_status: "draft" | "active" | "retired"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  temporal: {
    Tables: {
      correction_reason: {
        Row: {
          applies_to: string[]
          code: string
          description: string
        }
        Insert: {
          applies_to: string[]
          code: string
          description: string
        }
        Update: {
          applies_to?: string[]
          code?: string
          description?: string
        }
        Relationships: []
      }
      event: {
        Row: {
          created_at: string
          dedupe_key: string | null
          id: string
          kind: string
          object_entity_id: string | null
          relationship_id: string | null
          subject_entity_id: string
          tenant_id: string
        }
        Insert: {
          created_at?: string
          dedupe_key?: string | null
          id?: string
          kind: string
          object_entity_id?: string | null
          relationship_id?: string | null
          subject_entity_id: string
          tenant_id?: string
        }
        Update: {
          created_at?: string
          dedupe_key?: string | null
          id?: string
          kind?: string
          object_entity_id?: string | null
          relationship_id?: string | null
          subject_entity_id?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "event_kind_fkey"
            columns: ["kind"]
            isOneToOne: false
            referencedRelation: "event_kind"
            referencedColumns: ["code"]
          },
        ]
      }
      event_kind: {
        Row: {
          code: string
          description: string
          ends_stream_kind: string | null
          object_kinds: string[] | null
          starts_stream_kind: string | null
          subject_kinds: string[]
        }
        Insert: {
          code: string
          description: string
          ends_stream_kind?: string | null
          object_kinds?: string[] | null
          starts_stream_kind?: string | null
          subject_kinds: string[]
        }
        Update: {
          code?: string
          description?: string
          ends_stream_kind?: string | null
          object_kinds?: string[] | null
          starts_stream_kind?: string | null
          subject_kinds?: string[]
        }
        Relationships: [
          {
            foreignKeyName: "event_kind_ends_stream_kind_fkey"
            columns: ["ends_stream_kind"]
            isOneToOne: false
            referencedRelation: "stream_kind"
            referencedColumns: ["code"]
          },
          {
            foreignKeyName: "event_kind_starts_stream_kind_fkey"
            columns: ["starts_stream_kind"]
            isOneToOne: false
            referencedRelation: "stream_kind"
            referencedColumns: ["code"]
          },
        ]
      }
      event_occurrence: {
        Row: {
          belief: string
          created_at: string
          event_id: string
          extent_id: string | null
          id: string
          k_from: number
          k_to: number | null
          occurred_during: unknown
          occurrence_mode: string
          payload: Json
          primary_claim_id: string | null
          tenant_id: string
        }
        Insert: {
          belief?: string
          created_at?: string
          event_id: string
          extent_id?: string | null
          id?: string
          k_from: number
          k_to?: number | null
          occurred_during: unknown
          occurrence_mode: string
          payload?: Json
          primary_claim_id?: string | null
          tenant_id?: string
        }
        Update: {
          belief?: string
          created_at?: string
          event_id?: string
          extent_id?: string | null
          id?: string
          k_from?: number
          k_to?: number | null
          occurred_during?: unknown
          occurrence_mode?: string
          payload?: Json
          primary_claim_id?: string | null
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "event_occurrence_event_id_fkey"
            columns: ["event_id"]
            isOneToOne: false
            referencedRelation: "event"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "event_occurrence_extent_id_fkey"
            columns: ["extent_id"]
            isOneToOne: false
            referencedRelation: "extent"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "event_occurrence_tenant_id_event_id_fkey"
            columns: ["tenant_id", "event_id"]
            isOneToOne: false
            referencedRelation: "event"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "event_occurrence_tenant_id_extent_id_fkey"
            columns: ["tenant_id", "extent_id"]
            isOneToOne: false
            referencedRelation: "extent"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      extent: {
        Row: {
          earliest: string | null
          id: string
          latest: string | null
          locator_id: string | null
          precision: string
          source_text: string | null
          tenant_id: string
          timezone: string | null
        }
        Insert: {
          earliest?: string | null
          id?: string
          latest?: string | null
          locator_id?: string | null
          precision: string
          source_text?: string | null
          tenant_id?: string
          timezone?: string | null
        }
        Update: {
          earliest?: string | null
          id?: string
          latest?: string | null
          locator_id?: string | null
          precision?: string
          source_text?: string | null
          tenant_id?: string
          timezone?: string | null
        }
        Relationships: []
      }
      knowledge_batch: {
        Row: {
          idempotency_key: string
          input_digest: string
          knowledge_seq: number
          operation_id: string | null
          receipt_id: string
          recorded_at: string
          summary: Json
          tenant_id: string
        }
        Insert: {
          idempotency_key: string
          input_digest: string
          knowledge_seq: number
          operation_id?: string | null
          receipt_id: string
          recorded_at?: string
          summary?: Json
          tenant_id?: string
        }
        Update: {
          idempotency_key?: string
          input_digest?: string
          knowledge_seq?: number
          operation_id?: string | null
          receipt_id?: string
          recorded_at?: string
          summary?: Json
          tenant_id?: string
        }
        Relationships: []
      }
      knowledge_head: {
        Row: {
          knowledge_seq: number
          open_k: number | null
          open_xid: unknown
          tenant_id: string
          updated_at: string
        }
        Insert: {
          knowledge_seq?: number
          open_k?: number | null
          open_xid?: unknown
          tenant_id?: string
          updated_at?: string
        }
        Update: {
          knowledge_seq?: number
          open_k?: number | null
          open_xid?: unknown
          tenant_id?: string
          updated_at?: string
        }
        Relationships: []
      }
      segment: {
        Row: {
          amount: number | null
          belief: string
          caused_by_event_id: string | null
          correction_reason: string | null
          created_at: string
          currency: string | null
          extent_id: string | null
          id: string
          k_from: number
          k_to: number | null
          payload: Json
          primary_claim_id: string | null
          ref_entity_id: string | null
          replaces_segment_id: string | null
          revision_kind: string | null
          status: string | null
          stream_id: string
          temporal_basis: string
          tenant_id: string
          unit: string | null
          valid_during: unknown
        }
        Insert: {
          amount?: number | null
          belief?: string
          caused_by_event_id?: string | null
          correction_reason?: string | null
          created_at?: string
          currency?: string | null
          extent_id?: string | null
          id?: string
          k_from: number
          k_to?: number | null
          payload?: Json
          primary_claim_id?: string | null
          ref_entity_id?: string | null
          replaces_segment_id?: string | null
          revision_kind?: string | null
          status?: string | null
          stream_id: string
          temporal_basis: string
          tenant_id?: string
          unit?: string | null
          valid_during: unknown
        }
        Update: {
          amount?: number | null
          belief?: string
          caused_by_event_id?: string | null
          correction_reason?: string | null
          created_at?: string
          currency?: string | null
          extent_id?: string | null
          id?: string
          k_from?: number
          k_to?: number | null
          payload?: Json
          primary_claim_id?: string | null
          ref_entity_id?: string | null
          replaces_segment_id?: string | null
          revision_kind?: string | null
          status?: string | null
          stream_id?: string
          temporal_basis?: string
          tenant_id?: string
          unit?: string | null
          valid_during?: unknown
        }
        Relationships: [
          {
            foreignKeyName: "segment_caused_by_event_id_fkey"
            columns: ["caused_by_event_id"]
            isOneToOne: false
            referencedRelation: "event"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "segment_correction_reason_fkey"
            columns: ["correction_reason"]
            isOneToOne: false
            referencedRelation: "correction_reason"
            referencedColumns: ["code"]
          },
          {
            foreignKeyName: "segment_extent_id_fkey"
            columns: ["extent_id"]
            isOneToOne: false
            referencedRelation: "extent"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "segment_replaces_segment_id_fkey"
            columns: ["replaces_segment_id"]
            isOneToOne: false
            referencedRelation: "segment"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "segment_stream_id_fkey"
            columns: ["stream_id"]
            isOneToOne: false
            referencedRelation: "stream"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "segment_tenant_id_caused_by_event_id_fkey"
            columns: ["tenant_id", "caused_by_event_id"]
            isOneToOne: false
            referencedRelation: "event"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "segment_tenant_id_extent_id_fkey"
            columns: ["tenant_id", "extent_id"]
            isOneToOne: false
            referencedRelation: "extent"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "segment_tenant_id_replaces_segment_id_fkey"
            columns: ["tenant_id", "replaces_segment_id"]
            isOneToOne: false
            referencedRelation: "segment"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "segment_tenant_id_stream_id_fkey"
            columns: ["tenant_id", "stream_id"]
            isOneToOne: false
            referencedRelation: "stream"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      stream: {
        Row: {
          created_at: string
          id: string
          kind: string
          scope_key: string
          subject_entity_id: string | null
          subject_relationship_id: string | null
          tenant_id: string
        }
        Insert: {
          created_at?: string
          id?: string
          kind: string
          scope_key?: string
          subject_entity_id?: string | null
          subject_relationship_id?: string | null
          tenant_id?: string
        }
        Update: {
          created_at?: string
          id?: string
          kind?: string
          scope_key?: string
          subject_entity_id?: string | null
          subject_relationship_id?: string | null
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "stream_kind_fkey"
            columns: ["kind"]
            isOneToOne: false
            referencedRelation: "stream_kind"
            referencedColumns: ["code"]
          },
        ]
      }
      stream_kind: {
        Row: {
          code: string
          description: string
          payload_schema: Json
          ref_entity_kinds: string[] | null
          requires_amount: boolean
          requires_ref_entity: boolean
          status_values: string[] | null
          subject_kinds: string[]
          subject_mode: string
          unit_values: string[] | null
        }
        Insert: {
          code: string
          description: string
          payload_schema?: Json
          ref_entity_kinds?: string[] | null
          requires_amount?: boolean
          requires_ref_entity?: boolean
          status_values?: string[] | null
          subject_kinds?: string[]
          subject_mode: string
          unit_values?: string[] | null
        }
        Update: {
          code?: string
          description?: string
          payload_schema?: Json
          ref_entity_kinds?: string[] | null
          requires_amount?: boolean
          requires_ref_entity?: boolean
          status_values?: string[] | null
          subject_kinds?: string[]
          subject_mode?: string
          unit_values?: string[] | null
        }
        Relationships: []
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      admit_support: {
        Args: {
          p_claim: string
          p_locator: string
          p_occurrence: string
          p_role?: string
          p_segment: string
        }
        Returns: string
      }
      assert_event: {
        Args: {
          p_belief?: string
          p_claim?: string
          p_dedupe_key?: string
          p_extent?: string
          p_kind: string
          p_mode?: string
          p_object?: string
          p_occurred_during: unknown
          p_payload?: Json
          p_relationship?: string
          p_subject: string
        }
        Returns: string
      }
      assert_relationship: {
        Args: {
          p_claim?: string
          p_episode?: number
          p_extent?: string
          p_from: string
          p_kind: string
          p_properties?: Json
          p_qualifier?: string
          p_to: string
          p_valid_during?: unknown
        }
        Returns: string
      }
      assert_state: {
        Args: {
          p_amount?: number
          p_belief?: string
          p_caused_by_event?: string
          p_claim?: string
          p_correction_reason?: string
          p_currency?: string
          p_entity: string
          p_extent?: string
          p_payload?: Json
          p_ref_entity?: string
          p_relationship?: string
          p_revision_kind?: string
          p_scope_key?: string
          p_status?: string
          p_stream_kind: string
          p_temporal_basis?: string
          p_unit?: string
          p_valid_during: unknown
        }
        Returns: string
      }
      begin_batch: { Args: { p_expected_head?: number }; Returns: number }
      close_relationship: {
        Args: {
          p_claim?: string
          p_closed_kind: string
          p_event?: string
          p_extent?: string
          p_reason?: string
          p_relationship: string
          p_world_end?: string
        }
        Returns: undefined
      }
      close_segment: { Args: { p_segment: string }; Returns: undefined }
      commit_batch: {
        Args: {
          p_idempotency_key: string
          p_input_digest: string
          p_receipt: string
          p_summary?: Json
        }
        Returns: number
      }
      current_k: { Args: never; Returns: number }
      emit_outbox: {
        Args: { p_k: number; p_payload: Json; p_topic: string }
        Returns: string
      }
      lock_knowledge_head: {
        Args: { p_expected_head: number }
        Returns: number
      }
      make_extent: {
        Args: {
          p_earliest?: string
          p_latest?: string
          p_locator?: string
          p_precision: string
          p_source_text: string
          p_timezone?: string
        }
        Returns: string
      }
      payload_valid: {
        Args: { p_schema: Json; p_value: Json }
        Returns: boolean
      }
      withdraw_support: { Args: { p_support: string }; Returns: undefined }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  util: {
    Tables: {
      database_release: {
        Row: {
          components: Json
          contract_version: string
          migration_head: string
          migrations: number
          migrations_sha256: string
          release_seq: number
          stamped_at: string
          stamped_by: string
        }
        Insert: {
          components: Json
          contract_version: string
          migration_head: string
          migrations: number
          migrations_sha256: string
          release_seq?: never
          stamped_at?: string
          stamped_by: string
        }
        Update: {
          components?: Json
          contract_version?: string
          migration_head?: string
          migrations?: number
          migrations_sha256?: string
          release_seq?: never
          stamped_at?: string
          stamped_by?: string
        }
        Relationships: []
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      current_tenant_id: { Args: never; Returns: string }
      default_tenant_id: { Args: never; Returns: string }
      ensure_month_partitions: {
        Args: { p_months_ahead?: number }
        Returns: number
      }
      stamp_database_release: {
        Args: {
          p_components: Json
          p_contract_version: string
          p_migration_head: string
          p_migrations: number
          p_migrations_sha256: string
          p_stamped_by: string
        }
        Returns: Json
      }
      uuidv7: { Args: never; Returns: string }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  verification: {
    Tables: {
      claim_triage: {
        Row: {
          checkability: string
          claim_id: string
          components: Json
          decided_at: string
          decided_by: string
          disposition: string
          duplicate_of_claim_id: string | null
          id: string
          priority: number | null
          probe_id: string | null
          rationale: string
          review_state: string
          supersedes_id: string | null
          tenant_id: string
        }
        Insert: {
          checkability: string
          claim_id: string
          components?: Json
          decided_at?: string
          decided_by: string
          disposition: string
          duplicate_of_claim_id?: string | null
          id?: string
          priority?: number | null
          probe_id?: string | null
          rationale: string
          review_state?: string
          supersedes_id?: string | null
          tenant_id?: string
        }
        Update: {
          checkability?: string
          claim_id?: string
          components?: Json
          decided_at?: string
          decided_by?: string
          disposition?: string
          duplicate_of_claim_id?: string | null
          id?: string
          priority?: number | null
          probe_id?: string | null
          rationale?: string
          review_state?: string
          supersedes_id?: string | null
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "claim_triage_probe_id_fkey"
            columns: ["probe_id"]
            isOneToOne: false
            referencedRelation: "probe"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "claim_triage_supersedes_id_fkey"
            columns: ["supersedes_id"]
            isOneToOne: false
            referencedRelation: "claim_triage"
            referencedColumns: ["id"]
          },
        ]
      }
      probe: {
        Row: {
          budget_usd: number
          created_at: string
          designed_by: string
          designed_in_thread_id: string | null
          environment: Json
          hypothesis: string
          id: string
          kind: string
          matrix: Json
          model_policy: string
          script_path: string | null
          script_sha256: string | null
          slug: string
          state: string
          subject_entity_ids: string[]
          tenant_id: string
          title: string
        }
        Insert: {
          budget_usd?: number
          created_at?: string
          designed_by: string
          designed_in_thread_id?: string | null
          environment?: Json
          hypothesis: string
          id?: string
          kind: string
          matrix?: Json
          model_policy?: string
          script_path?: string | null
          script_sha256?: string | null
          slug: string
          state?: string
          subject_entity_ids?: string[]
          tenant_id?: string
          title: string
        }
        Update: {
          budget_usd?: number
          created_at?: string
          designed_by?: string
          designed_in_thread_id?: string | null
          environment?: Json
          hypothesis?: string
          id?: string
          kind?: string
          matrix?: Json
          model_policy?: string
          script_path?: string | null
          script_sha256?: string | null
          slug?: string
          state?: string
          subject_entity_ids?: string[]
          tenant_id?: string
          title?: string
        }
        Relationships: []
      }
      probe_claim: {
        Row: {
          claim_id: string
          expectation: Json
          probe_id: string
          tenant_id: string
        }
        Insert: {
          claim_id: string
          expectation?: Json
          probe_id: string
          tenant_id?: string
        }
        Update: {
          claim_id?: string
          expectation?: Json
          probe_id?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "probe_claim_probe_id_fkey"
            columns: ["probe_id"]
            isOneToOne: false
            referencedRelation: "probe"
            referencedColumns: ["id"]
          },
        ]
      }
      probe_run: {
        Row: {
          cell: Json
          cell_label: string
          cost_usd: number | null
          created_at: string
          ended_at: string | null
          exit_code: number | null
          id: string
          latency_ms: number | null
          lock_sha256: string | null
          mission_id: string | null
          observations: Json
          origin_kind: string
          outcome: string
          output_capture_id: string | null
          output_locator_id: string | null
          platform: string | null
          probe_id: string
          python_version: string | null
          receipt_id: string | null
          resolved: Json
          started_at: string
          sweep_id: string | null
          tenant_id: string
          tokens_in: number | null
          tokens_out: number | null
        }
        Insert: {
          cell?: Json
          cell_label: string
          cost_usd?: number | null
          created_at?: string
          ended_at?: string | null
          exit_code?: number | null
          id?: string
          latency_ms?: number | null
          lock_sha256?: string | null
          mission_id?: string | null
          observations?: Json
          origin_kind?: string
          outcome: string
          output_capture_id?: string | null
          output_locator_id?: string | null
          platform?: string | null
          probe_id: string
          python_version?: string | null
          receipt_id?: string | null
          resolved?: Json
          started_at: string
          sweep_id?: string | null
          tenant_id?: string
          tokens_in?: number | null
          tokens_out?: number | null
        }
        Update: {
          cell?: Json
          cell_label?: string
          cost_usd?: number | null
          created_at?: string
          ended_at?: string | null
          exit_code?: number | null
          id?: string
          latency_ms?: number | null
          lock_sha256?: string | null
          mission_id?: string | null
          observations?: Json
          origin_kind?: string
          outcome?: string
          output_capture_id?: string | null
          output_locator_id?: string | null
          platform?: string | null
          probe_id?: string
          python_version?: string | null
          receipt_id?: string | null
          resolved?: Json
          started_at?: string
          sweep_id?: string | null
          tenant_id?: string
          tokens_in?: number | null
          tokens_out?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "probe_run_probe_id_fkey"
            columns: ["probe_id"]
            isOneToOne: false
            referencedRelation: "probe"
            referencedColumns: ["id"]
          },
        ]
      }
      probe_verdict: {
        Row: {
          cells: Json
          claim_id: string
          decided_at: string
          decided_by: string
          id: string
          probe_id: string
          rationale: string
          review_state: string
          supersedes_id: string | null
          tenant_id: string
          verdict: Database["evidence"]["Enums"]["support_verdict"]
        }
        Insert: {
          cells?: Json
          claim_id: string
          decided_at?: string
          decided_by: string
          id?: string
          probe_id: string
          rationale: string
          review_state?: string
          supersedes_id?: string | null
          tenant_id?: string
          verdict: Database["evidence"]["Enums"]["support_verdict"]
        }
        Update: {
          cells?: Json
          claim_id?: string
          decided_at?: string
          decided_by?: string
          id?: string
          probe_id?: string
          rationale?: string
          review_state?: string
          supersedes_id?: string | null
          tenant_id?: string
          verdict?: Database["evidence"]["Enums"]["support_verdict"]
        }
        Relationships: [
          {
            foreignKeyName: "probe_verdict_probe_id_fkey"
            columns: ["probe_id"]
            isOneToOne: false
            referencedRelation: "probe"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "probe_verdict_supersedes_id_fkey"
            columns: ["supersedes_id"]
            isOneToOne: false
            referencedRelation: "probe_verdict"
            referencedColumns: ["id"]
          },
        ]
      }
      use_admission: {
        Row: {
          admitted_at: string
          authoritative_epoch: number
          bound_effect_digest: string
          effect_key: string
          normalized_values_digest: string | null
          processed_epoch: number
          tenant_id: string
          use_decision_id: string
          xact_id: number
        }
        Insert: {
          admitted_at?: string
          authoritative_epoch: number
          bound_effect_digest: string
          effect_key: string
          normalized_values_digest?: string | null
          processed_epoch: number
          tenant_id?: string
          use_decision_id: string
          xact_id: number
        }
        Update: {
          admitted_at?: string
          authoritative_epoch?: number
          bound_effect_digest?: string
          effect_key?: string
          normalized_values_digest?: string | null
          processed_epoch?: number
          tenant_id?: string
          use_decision_id?: string
          xact_id?: number
        }
        Relationships: []
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      assert_admitted_use: {
        Args: {
          p_bound_effect_digest: string
          p_normalized_values_digest?: string
          p_processed_epoch: number
          p_tenant: string
          p_use_decision_id: string
        }
        Returns: {
          admitted_at: string
          authoritative_epoch: number
          bound_effect_digest: string
          effect_key: string
          normalized_values_digest: string | null
          processed_epoch: number
          tenant_id: string
          use_decision_id: string
          xact_id: number
        }
        SetofOptions: {
          from: "*"
          to: "use_admission"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      chain_anchor: {
        Args: { p_function: string; p_spec: Json; p_tenant: string }
        Returns: Record<string, unknown>
      }
      chain_begin: {
        Args: {
          p_actor: Json
          p_function: string
          p_key: string
          p_request: Json
        }
        Returns: Json
      }
      chain_fail: {
        Args: { p_code: string; p_detail?: string; p_state: string }
        Returns: undefined
      }
      chain_norm: { Args: { p_text: string }; Returns: string }
      chain_record: {
        Args: {
          p_ctx: Json
          p_function: string
          p_refs: Json
          p_request: Json
          p_result: Json
        }
        Returns: Json
      }
      chain_sha: { Args: { p_text: string }; Returns: string }
      chain_target: {
        Args: {
          p_action: string
          p_claim?: string
          p_ctx: Json
          p_id: string
          p_receipt: string
          p_role: string
          p_schema: string
          p_table: string
        }
        Returns: undefined
      }
      chain_uuid: { Args: { p_code: string; p_text: string }; Returns: string }
      record_admitted_claim_verification: {
        Args: {
          p_bound_effect_digest: string
          p_claim: string
          p_effect_text: string
          p_executor: string
          p_normalized_values_digest: string
          p_origin_digest: string
          p_processed_epoch: number
          p_use_decision_id: string
        }
        Returns: string
      }
      require_admitted_use: {
        Args: {
          p_bound_effect_digest: string
          p_normalized_values_digest?: string
          p_processed_epoch: number
          p_tenant: string
          p_use_decision_id: string
        }
        Returns: {
          authoritative_epoch: number
          effect_key: string
        }[]
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  access: {
    Enums: {},
  },
  acquisition: {
    Enums: {},
  },
  api: {
    Enums: {},
  },
  authoring: {
    Enums: {},
  },
  catalog: {
    Enums: {},
  },
  content: {
    Enums: {},
  },
  conversation: {
    Enums: {},
  },
  curriculum: {
    Enums: {},
  },
  dataset: {
    Enums: {},
  },
  evaluation: {
    Enums: {
      gate_action: [
        "block",
        "quarantine",
        "repair",
        "rerun",
        "review",
        "escalate",
        "optimize",
        "allow",
      ],
      review_state: [
        "open",
        "claimed",
        "in_review",
        "decided",
        "escalated",
        "cancelled",
      ],
    },
  },
  evidence: {
    Enums: {
      claim_status: [
        "proposed",
        "verified",
        "disputed",
        "retracted",
        "superseded",
      ],
      support_verdict: [
        "directly_supported",
        "supported_with_qualification",
        "partially_supported",
        "context_only",
        "contradicted",
        "not_supported",
        "unverifiable",
        "pending_semantic_review",
        "mixed_or_conflicting",
        "insufficient_evidence",
        "source_unavailable",
        "locator_error",
        "parser_error",
        "derived_verified",
        "derived_failed",
      ],
    },
  },
  guidance: {
    Enums: {
      maturity: ["experimental", "emerging", "established", "declining"],
      revalidation_state: [
        "fresh",
        "due",
        "in_progress",
        "stale",
        "failed",
        "retired",
      ],
    },
  },
  inquiry: {
    Enums: {},
  },
  knowledge_service: {
    Enums: {},
  },
  learning: {
    Enums: {},
  },
  library: {
    Enums: {},
  },
  observability: {
    Enums: {},
  },
  orchestration: {
    Enums: {
      attempt_outcome: [
        "succeeded",
        "failed",
        "timeout",
        "cancelled",
        "rejected",
      ],
      bucket_class: [
        "source_captures",
        "candidate",
        "accepted",
        "ledger",
        "published",
        "workspace",
      ],
      mission_status: [
        "created",
        "planning",
        "running",
        "paused",
        "blocked",
        "succeeded",
        "failed",
        "cancelled",
        "superseded",
      ],
      work_item_status: [
        "pending",
        "ready",
        "running",
        "blocked",
        "succeeded",
        "failed",
        "cancelled",
        "skipped",
      ],
    },
  },
  product: {
    Enums: {},
  },
  public: {
    Enums: {
      research_category_assignment_role: ["primary", "secondary"],
      research_content_form: [
        "talk",
        "tutorial",
        "demo",
        "panel",
        "interview",
        "workshop",
        "keynote",
      ],
      research_difficulty: [
        "introductory",
        "intermediate",
        "advanced",
        "expert",
      ],
      research_engineering_category_code: [
        "model_foundations_behavior",
        "inference_model_systems",
        "ai_data_engineering",
        "post_training_continual_learning",
        "prompting_llm_programming",
        "context_engineering_memory",
        "retrieval_search_knowledge",
        "agent_architecture_harnesses",
        "tools_protocols_integrations",
        "orchestration_durable_execution",
        "coding_agents_software_engineering",
        "evaluation_testing_benchmarking",
        "observability_reliability_llmops",
        "security_safety_identity_governance",
        "multimodal_realtime_systems",
        "ai_product_ux_human_factors",
        "ai_platforms_developer_tooling",
        "model_behavior",
        "inference_serving",
        "training_and_post_training",
        "data_for_models",
        "prompting",
        "context_and_memory",
        "retrieval_and_search",
        "single_agent_loops",
        "multi_agent_coordination",
        "agent_harnesses",
        "tools_and_protocols",
        "durable_workflows",
        "coding_agents",
        "evaluation",
        "observability_and_ops",
        "security_and_governance",
        "voice_and_speech",
        "vision_multimodal_robotics",
        "product_ux",
        "platforms_and_gateways",
        "research_automation",
        "org_adoption",
        "multi_talk_compilation",
        "insufficient_evidence",
      ],
      research_entity_kind: [
        "person",
        "organization",
        "product",
        "model",
        "protocol",
        "dataset",
        "benchmark",
        "paper",
        "repository",
        "other",
      ],
      research_evidence_level: [
        "anecdotal",
        "case_study",
        "benchmarked",
        "production_system",
        "research_paper",
      ],
      research_evidence_source_kind: ["transcript", "description", "web"],
      research_intent_event_status: ["pending", "applied", "skipped", "failed"],
      research_intent_status: ["draft", "validated", "applied", "rejected"],
      research_lifecycle_stage: [
        "research",
        "design",
        "implementation",
        "evaluation",
        "deployment",
        "operations",
        "governance",
      ],
      research_organization_domain_code: [
        "frontier_model_lab",
        "applied_ai_research_lab",
        "cloud_ai_platform",
        "ai_compute_hardware_systems",
        "model_training_inference_platform",
        "ai_data_curation_training_platform",
        "database_data_ai_platform",
        "retrieval_knowledge_platform",
        "agent_framework_orchestration",
        "ai_developer_platform_sdk",
        "coding_agents_developer_tools",
        "evaluation_observability_llmops",
        "ai_security_identity_governance",
        "multimodal_voice_media_ai",
        "robotics_embodied_edge_ai",
        "enterprise_ai_automation",
        "horizontal_ai_application",
        "vertical_ai_application",
        "open_source_ai_ecosystem",
        "ai_protocol_standards_body",
        "academic_nonprofit_research",
        "ai_services_consulting",
        "ai_community_education_media",
        "ai_adopting_product_company",
        "general_technology_ai_unit",
        "diversified_technology_company",
        "other_unknown",
      ],
      research_organization_scope: [
        "independent_company",
        "parent_company",
        "subsidiary",
        "division",
        "research_lab",
        "product_organization",
        "standards_body",
        "academic_institution",
        "nonprofit",
        "community_education_media",
        "other",
      ],
      research_pre_research_run_status: [
        "queued",
        "claimed",
        "analyzing",
        "intent_ready",
        "applying",
        "applied",
        "review_required",
        "failed",
        "superseded",
        "research_complete",
        "synthesizing",
      ],
      research_resource_type: [
        "repository",
        "code_example",
        "documentation",
        "paper",
        "article",
        "slides",
        "dataset",
        "benchmark",
        "model",
        "demo",
        "course",
        "other",
      ],
      research_taxonomy_status: ["draft", "active", "retired"],
      research_verification_status: [
        "verified",
        "likely",
        "uncertain",
        "rejected",
      ],
      research_video_organization_role: [
        "primary_featured_organization",
        "implementation_owner",
        "speaker_employer",
        "parent_organization",
        "subsidiary_or_division",
        "acquisition_party",
        "partner",
        "customer_or_internal_user",
        "standards_steward",
        "mentioned_only",
      ],
    },
  },
  ranking: {
    Enums: {
      approval_state: [
        "draft",
        "proposed",
        "approved",
        "deprecated",
        "rejected",
      ],
    },
  },
  retrieval: {
    Enums: {
      backend_kind: ["vector_bucket", "pgvector"],
      space_class: ["canonical", "exploratory"],
    },
  },
  staging: {
    Enums: {
      candidate_status: [
        "discovered",
        "enriched",
        "matched",
        "resolved",
        "promoted",
        "quarantined",
        "rejected",
      ],
      resolution_outcome: [
        "insert",
        "update",
        "link",
        "merge",
        "supersede",
        "no_op",
        "quarantine",
        "reject",
        "review",
      ],
      vetting_outcome: [
        "approved_for_metrics",
        "approved_for_research",
        "approved_provisionally",
        "deferred",
        "insufficient_evidence",
        "out_of_scope",
        "rejected",
      ],
    },
  },
  taxonomy: {
    Enums: {
      facet_status: ["draft", "active", "retired"],
    },
  },
  temporal: {
    Enums: {},
  },
  util: {
    Enums: {},
  },
  verification: {
    Enums: {},
  },
} as const
