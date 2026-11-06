export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  api: {
    Tables: {
      [_ in never]: never
    }
    Views: {
      current_facts: {
        Row: {
          amount: number | null
          belief: string | null
          caused_by_event_id: string | null
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
          scope_key: string | null
          specification_id: string | null
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
      library_profile: {
        Row: {
          created_at: string | null
          created_by_receipt_id: string | null
          display_name: string | null
          ecosystem: string | null
          id: string | null
          kind: string | null
          lifecycle: string | null
          merged_into_id: string | null
          package_name: string | null
          projection_knowledge_seq: number | null
          slug: string | null
          summary: string | null
          tenant_id: string | null
          updated_at: string | null
        }
        Relationships: [
          {
            foreignKeyName: "entity_merged_into_id_fkey"
            columns: ["merged_into_id"]
            isOneToOne: false
            referencedRelation: "library_profile"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "entity_tenant_id_merged_into_id_fkey"
            columns: ["tenant_id", "merged_into_id"]
            isOneToOne: false
            referencedRelation: "library_profile"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
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
          ranking_result_id: string | null
          record_reconciliation_id: string | null
          report_version_id: string | null
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
          ranking_result_id?: string | null
          record_reconciliation_id?: string | null
          report_version_id?: string | null
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
          ranking_result_id?: string | null
          record_reconciliation_id?: string | null
          report_version_id?: string | null
          state?: Database["evaluation"]["Enums"]["review_state"] | null
          subject_kind?: string | null
          summary?: string | null
          task_kind?: string | null
          tenant_id?: string | null
          updated_at?: string | null
          vector_space_version_id?: string | null
        }
        Relationships: []
      }
      technical_record_search: {
        Row: {
          assurance_level: string | null
          created_at: string | null
          created_by_receipt_id: string | null
          id: string | null
          kind: string | null
          provenance_claim_id: string | null
          scope: Json | null
          statement: string | null
          tenant_id: string | null
          title: string | null
        }
        Insert: {
          assurance_level?: string | null
          created_at?: string | null
          created_by_receipt_id?: string | null
          id?: string | null
          kind?: string | null
          provenance_claim_id?: string | null
          scope?: Json | null
          statement?: string | null
          tenant_id?: string | null
          title?: string | null
        }
        Update: {
          assurance_level?: string | null
          created_at?: string | null
          created_by_receipt_id?: string | null
          id?: string | null
          kind?: string | null
          provenance_claim_id?: string | null
          scope?: Json | null
          statement?: string | null
          tenant_id?: string | null
          title?: string | null
        }
        Relationships: []
      }
    }
    Functions: {
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
          scope_key: string
          specification_id: string
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
        Returns: Database["corpus"]["Tables"]["relationship"]["Row"][]
        SetofOptions: {
          from: "*"
          to: "relationship"
          isOneToOne: false
          isSetofReturn: true
        }
      }
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
      entity_rows: {
        Args: never
        Returns: Database["corpus"]["Tables"]["entity"]["Row"][]
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
      knowledge_head: {
        Args: never
        Returns: {
          knowledge_seq: number
          updated_at: string
        }[]
      }
      leaderboard: {
        Args: { p_limit?: number }
        Returns: Database["ranking"]["Tables"]["ranking_result"]["Row"][]
        SetofOptions: {
          from: "*"
          to: "ranking_result"
          isOneToOne: false
          isSetofReturn: true
        }
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
      product_worker: {
        Args: { p_operation: string; p_payload: Json }
        Returns: Json
      }
      relationships: {
        Args: {
          p_at?: string
          p_direction?: string
          p_entity: string
          p_k?: number
          p_kind?: string
        }
        Returns: Database["corpus"]["Tables"]["relationship"]["Row"][]
        SetofOptions: {
          from: "*"
          to: "relationship"
          isOneToOne: false
          isSetofReturn: true
        }
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
      document: {
        Row: {
          canonical_source_id: string | null
          canonical_title: string
          created_at: string
          created_by_attempt_id: string | null
          document_type_code: string
          id: string
          lifecycle: string
          repository_file_id: string | null
          supersedes_id: string | null
          tenant_id: string
          work_entity_id: string | null
        }
        Insert: {
          canonical_source_id?: string | null
          canonical_title: string
          created_at?: string
          created_by_attempt_id?: string | null
          document_type_code: string
          id?: string
          lifecycle?: string
          repository_file_id?: string | null
          supersedes_id?: string | null
          tenant_id?: string
          work_entity_id?: string | null
        }
        Update: {
          canonical_source_id?: string | null
          canonical_title?: string
          created_at?: string
          created_by_attempt_id?: string | null
          document_type_code?: string
          id?: string
          lifecycle?: string
          repository_file_id?: string | null
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
      document_node: {
        Row: {
          artifact_id: string | null
          bbox: Json | null
          created_at: string
          end_ms: number | null
          end_offset: number | null
          id: string
          inline_text: string | null
          language: string | null
          node_kind: string
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
        }
        Insert: {
          artifact_id?: string | null
          bbox?: Json | null
          created_at?: string
          end_ms?: number | null
          end_offset?: number | null
          id?: string
          inline_text?: string | null
          language?: string | null
          node_kind: string
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
        }
        Update: {
          artifact_id?: string | null
          bbox?: Json | null
          created_at?: string
          end_ms?: number | null
          end_offset?: number | null
          id?: string
          inline_text?: string | null
          language?: string | null
          node_kind?: string
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
          code: string
          default_chunking_slug: string
          default_extraction_kinds: string[]
          default_spaces: string[]
          default_summary_kinds: string[]
          description: string
          family: string
          is_primary_source: boolean
          published_at_is_world_time: boolean
          work_entity_kind: string | null
        }
        Insert: {
          code: string
          default_chunking_slug: string
          default_extraction_kinds: string[]
          default_spaces: string[]
          default_summary_kinds?: string[]
          description: string
          family: string
          is_primary_source: boolean
          published_at_is_world_time?: boolean
          work_entity_kind?: string | null
        }
        Update: {
          code?: string
          default_chunking_slug?: string
          default_extraction_kinds?: string[]
          default_spaces?: string[]
          default_summary_kinds?: string[]
          description?: string
          family?: string
          is_primary_source?: boolean
          published_at_is_world_time?: boolean
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
  corpus: {
    Tables: {
      agent_skill: {
        Row: {
          description: string | null
          id: string
          kind: string
          skill_format: string | null
          tenant_id: string
        }
        Insert: {
          description?: string | null
          id: string
          kind?: string
          skill_format?: string | null
          tenant_id?: string
        }
        Update: {
          description?: string | null
          id?: string
          kind?: string
          skill_format?: string | null
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "agent_skill_id_fkey"
            columns: ["id"]
            isOneToOne: true
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "agent_skill_tenant_id_id_fkey"
            columns: ["tenant_id", "id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "agent_skill_tenant_id_id_kind_fkey"
            columns: ["tenant_id", "id", "kind"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id", "kind"]
          },
        ]
      }
      ai_model: {
        Row: {
          description: string | null
          id: string
          kind: string
          modality: string[] | null
          model_family: string | null
          tenant_id: string
        }
        Insert: {
          description?: string | null
          id: string
          kind?: string
          modality?: string[] | null
          model_family?: string | null
          tenant_id?: string
        }
        Update: {
          description?: string | null
          id?: string
          kind?: string
          modality?: string[] | null
          model_family?: string | null
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "ai_model_id_fkey"
            columns: ["id"]
            isOneToOne: true
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "ai_model_tenant_id_id_fkey"
            columns: ["tenant_id", "id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "ai_model_tenant_id_id_kind_fkey"
            columns: ["tenant_id", "id", "kind"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id", "kind"]
          },
        ]
      }
      ai_model_version: {
        Row: {
          ai_model_id: string
          id: string
          kind: string
          provider_model_id: string | null
          tenant_id: string
          version_label: string
        }
        Insert: {
          ai_model_id: string
          id: string
          kind?: string
          provider_model_id?: string | null
          tenant_id?: string
          version_label: string
        }
        Update: {
          ai_model_id?: string
          id?: string
          kind?: string
          provider_model_id?: string | null
          tenant_id?: string
          version_label?: string
        }
        Relationships: [
          {
            foreignKeyName: "ai_model_version_ai_model_id_fkey"
            columns: ["ai_model_id"]
            isOneToOne: false
            referencedRelation: "ai_model"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "ai_model_version_id_fkey"
            columns: ["id"]
            isOneToOne: true
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "ai_model_version_tenant_id_ai_model_id_fkey"
            columns: ["tenant_id", "ai_model_id"]
            isOneToOne: false
            referencedRelation: "ai_model"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "ai_model_version_tenant_id_id_fkey"
            columns: ["tenant_id", "id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "ai_model_version_tenant_id_id_kind_fkey"
            columns: ["tenant_id", "id", "kind"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id", "kind"]
          },
        ]
      }
      ai_model_version_spec: {
        Row: {
          context_tokens: number | null
          id: string
          modalities: string[] | null
          model_version_id: string
          parameters_billions: number | null
          source_claim_id: string | null
          specification: Json
          tenant_id: string
        }
        Insert: {
          context_tokens?: number | null
          id?: string
          modalities?: string[] | null
          model_version_id: string
          parameters_billions?: number | null
          source_claim_id?: string | null
          specification?: Json
          tenant_id?: string
        }
        Update: {
          context_tokens?: number | null
          id?: string
          modalities?: string[] | null
          model_version_id?: string
          parameters_billions?: number | null
          source_claim_id?: string | null
          specification?: Json
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "ai_model_version_spec_model_version_id_fkey"
            columns: ["model_version_id"]
            isOneToOne: false
            referencedRelation: "ai_model_version"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "ai_model_version_spec_tenant_id_model_version_id_fkey"
            columns: ["tenant_id", "model_version_id"]
            isOneToOne: false
            referencedRelation: "ai_model_version"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      ai_protocol: {
        Row: {
          description: string | null
          id: string
          kind: string
          specification_url: string | null
          tenant_id: string
        }
        Insert: {
          description?: string | null
          id: string
          kind?: string
          specification_url?: string | null
          tenant_id?: string
        }
        Update: {
          description?: string | null
          id?: string
          kind?: string
          specification_url?: string | null
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "ai_protocol_id_fkey"
            columns: ["id"]
            isOneToOne: true
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "ai_protocol_tenant_id_id_fkey"
            columns: ["tenant_id", "id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "ai_protocol_tenant_id_id_kind_fkey"
            columns: ["tenant_id", "id", "kind"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id", "kind"]
          },
        ]
      }
      ai_protocol_feature: {
        Row: {
          ai_protocol_id: string
          description: string | null
          feature_key: string
          id: string
          kind: string
          tenant_id: string
        }
        Insert: {
          ai_protocol_id: string
          description?: string | null
          feature_key: string
          id: string
          kind?: string
          tenant_id?: string
        }
        Update: {
          ai_protocol_id?: string
          description?: string | null
          feature_key?: string
          id?: string
          kind?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "ai_protocol_feature_ai_protocol_id_fkey"
            columns: ["ai_protocol_id"]
            isOneToOne: false
            referencedRelation: "ai_protocol"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "ai_protocol_feature_id_fkey"
            columns: ["id"]
            isOneToOne: true
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "ai_protocol_feature_tenant_id_ai_protocol_id_fkey"
            columns: ["tenant_id", "ai_protocol_id"]
            isOneToOne: false
            referencedRelation: "ai_protocol"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "ai_protocol_feature_tenant_id_id_fkey"
            columns: ["tenant_id", "id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "ai_protocol_feature_tenant_id_id_kind_fkey"
            columns: ["tenant_id", "id", "kind"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id", "kind"]
          },
        ]
      }
      ai_protocol_version: {
        Row: {
          ai_protocol_id: string
          id: string
          kind: string
          specification_url: string | null
          tenant_id: string
          version_label: string
        }
        Insert: {
          ai_protocol_id: string
          id: string
          kind?: string
          specification_url?: string | null
          tenant_id?: string
          version_label: string
        }
        Update: {
          ai_protocol_id?: string
          id?: string
          kind?: string
          specification_url?: string | null
          tenant_id?: string
          version_label?: string
        }
        Relationships: [
          {
            foreignKeyName: "ai_protocol_version_ai_protocol_id_fkey"
            columns: ["ai_protocol_id"]
            isOneToOne: false
            referencedRelation: "ai_protocol"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "ai_protocol_version_id_fkey"
            columns: ["id"]
            isOneToOne: true
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "ai_protocol_version_tenant_id_ai_protocol_id_fkey"
            columns: ["tenant_id", "ai_protocol_id"]
            isOneToOne: false
            referencedRelation: "ai_protocol"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "ai_protocol_version_tenant_id_id_fkey"
            columns: ["tenant_id", "id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "ai_protocol_version_tenant_id_id_kind_fkey"
            columns: ["tenant_id", "id", "kind"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id", "kind"]
          },
        ]
      }
      benchmark: {
        Row: {
          canonical_url: string | null
          id: string
          kind: string
          methodology: string | null
          tenant_id: string
        }
        Insert: {
          canonical_url?: string | null
          id: string
          kind?: string
          methodology?: string | null
          tenant_id?: string
        }
        Update: {
          canonical_url?: string | null
          id?: string
          kind?: string
          methodology?: string | null
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "benchmark_id_fkey"
            columns: ["id"]
            isOneToOne: true
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "benchmark_tenant_id_id_fkey"
            columns: ["tenant_id", "id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "benchmark_tenant_id_id_kind_fkey"
            columns: ["tenant_id", "id", "kind"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id", "kind"]
          },
        ]
      }
      benchmark_run: {
        Row: {
          artifact_id: string | null
          benchmark_id: string
          id: string
          kind: string
          protocol: Json
          subject_entity_id: string
          tenant_id: string
        }
        Insert: {
          artifact_id?: string | null
          benchmark_id: string
          id: string
          kind?: string
          protocol?: Json
          subject_entity_id: string
          tenant_id?: string
        }
        Update: {
          artifact_id?: string | null
          benchmark_id?: string
          id?: string
          kind?: string
          protocol?: Json
          subject_entity_id?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "benchmark_run_benchmark_id_fkey"
            columns: ["benchmark_id"]
            isOneToOne: false
            referencedRelation: "benchmark"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "benchmark_run_id_fkey"
            columns: ["id"]
            isOneToOne: true
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "benchmark_run_subject_entity_id_fkey"
            columns: ["subject_entity_id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "benchmark_run_tenant_id_benchmark_id_fkey"
            columns: ["tenant_id", "benchmark_id"]
            isOneToOne: false
            referencedRelation: "benchmark"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "benchmark_run_tenant_id_id_fkey"
            columns: ["tenant_id", "id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "benchmark_run_tenant_id_id_kind_fkey"
            columns: ["tenant_id", "id", "kind"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id", "kind"]
          },
          {
            foreignKeyName: "benchmark_run_tenant_id_subject_entity_id_fkey"
            columns: ["tenant_id", "subject_entity_id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      case_study: {
        Row: {
          abstract: string | null
          canonical_url: string | null
          id: string
          kind: string
          tenant_id: string
          title: string
        }
        Insert: {
          abstract?: string | null
          canonical_url?: string | null
          id: string
          kind?: string
          tenant_id?: string
          title: string
        }
        Update: {
          abstract?: string | null
          canonical_url?: string | null
          id?: string
          kind?: string
          tenant_id?: string
          title?: string
        }
        Relationships: [
          {
            foreignKeyName: "case_study_id_fkey"
            columns: ["id"]
            isOneToOne: true
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "case_study_tenant_id_id_fkey"
            columns: ["tenant_id", "id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "case_study_tenant_id_id_kind_fkey"
            columns: ["tenant_id", "id", "kind"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id", "kind"]
          },
        ]
      }
      compute_device: {
        Row: {
          architecture: string | null
          device_kind: string | null
          id: string
          kind: string
          manufacturer_entity_id: string | null
          memory_gb: number | null
          tenant_id: string
        }
        Insert: {
          architecture?: string | null
          device_kind?: string | null
          id: string
          kind?: string
          manufacturer_entity_id?: string | null
          memory_gb?: number | null
          tenant_id?: string
        }
        Update: {
          architecture?: string | null
          device_kind?: string | null
          id?: string
          kind?: string
          manufacturer_entity_id?: string | null
          memory_gb?: number | null
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "compute_device_id_fkey"
            columns: ["id"]
            isOneToOne: true
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "compute_device_manufacturer_entity_id_fkey"
            columns: ["manufacturer_entity_id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "compute_device_tenant_id_id_fkey"
            columns: ["tenant_id", "id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "compute_device_tenant_id_id_kind_fkey"
            columns: ["tenant_id", "id", "kind"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id", "kind"]
          },
          {
            foreignKeyName: "compute_device_tenant_id_manufacturer_entity_id_fkey"
            columns: ["tenant_id", "manufacturer_entity_id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      compute_offering: {
        Row: {
          id: string
          kind: string
          offering_key: string | null
          provider_entity_id: string | null
          region: string | null
          tenant_id: string
        }
        Insert: {
          id: string
          kind?: string
          offering_key?: string | null
          provider_entity_id?: string | null
          region?: string | null
          tenant_id?: string
        }
        Update: {
          id?: string
          kind?: string
          offering_key?: string | null
          provider_entity_id?: string | null
          region?: string | null
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "compute_offering_id_fkey"
            columns: ["id"]
            isOneToOne: true
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "compute_offering_provider_entity_id_fkey"
            columns: ["provider_entity_id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "compute_offering_tenant_id_id_fkey"
            columns: ["tenant_id", "id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "compute_offering_tenant_id_id_kind_fkey"
            columns: ["tenant_id", "id", "kind"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id", "kind"]
          },
          {
            foreignKeyName: "compute_offering_tenant_id_provider_entity_id_fkey"
            columns: ["tenant_id", "provider_entity_id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      concept: {
        Row: {
          description: string | null
          id: string
          kind: string
          tenant_id: string
        }
        Insert: {
          description?: string | null
          id: string
          kind?: string
          tenant_id?: string
        }
        Update: {
          description?: string | null
          id?: string
          kind?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "concept_id_fkey"
            columns: ["id"]
            isOneToOne: true
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "concept_tenant_id_id_fkey"
            columns: ["tenant_id", "id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "concept_tenant_id_id_kind_fkey"
            columns: ["tenant_id", "id", "kind"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id", "kind"]
          },
        ]
      }
      corporate_transaction: {
        Row: {
          announced_on: string | null
          description: string | null
          id: string
          kind: string
          tenant_id: string
          transaction_kind: string | null
        }
        Insert: {
          announced_on?: string | null
          description?: string | null
          id: string
          kind?: string
          tenant_id?: string
          transaction_kind?: string | null
        }
        Update: {
          announced_on?: string | null
          description?: string | null
          id?: string
          kind?: string
          tenant_id?: string
          transaction_kind?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "corporate_transaction_id_fkey"
            columns: ["id"]
            isOneToOne: true
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "corporate_transaction_tenant_id_id_fkey"
            columns: ["tenant_id", "id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "corporate_transaction_tenant_id_id_kind_fkey"
            columns: ["tenant_id", "id", "kind"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id", "kind"]
          },
        ]
      }
      dataset: {
        Row: {
          canonical_url: string | null
          dataset_kind: string | null
          id: string
          kind: string
          license_code: string | null
          tenant_id: string
        }
        Insert: {
          canonical_url?: string | null
          dataset_kind?: string | null
          id: string
          kind?: string
          license_code?: string | null
          tenant_id?: string
        }
        Update: {
          canonical_url?: string | null
          dataset_kind?: string | null
          id?: string
          kind?: string
          license_code?: string | null
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "dataset_id_fkey"
            columns: ["id"]
            isOneToOne: true
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "dataset_license_code_fkey"
            columns: ["license_code"]
            isOneToOne: false
            referencedRelation: "license"
            referencedColumns: ["code"]
          },
          {
            foreignKeyName: "dataset_tenant_id_id_fkey"
            columns: ["tenant_id", "id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "dataset_tenant_id_id_kind_fkey"
            columns: ["tenant_id", "id", "kind"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id", "kind"]
          },
        ]
      }
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
          reason: string
          receipt_id: string
          tenant_id: string
          to_entity_id: string
        }
        Insert: {
          created_at?: string
          from_entity_id: string
          id?: string
          reason: string
          receipt_id: string
          tenant_id?: string
          to_entity_id: string
        }
        Update: {
          created_at?: string
          from_entity_id?: string
          id?: string
          reason?: string
          receipt_id?: string
          tenant_id?: string
          to_entity_id?: string
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
      event_series: {
        Row: {
          id: string
          kind: string
          name: string
          organizer_entity_id: string | null
          series_kind: string
          slug: string
          tenant_id: string
          website_url: string | null
        }
        Insert: {
          id: string
          kind?: string
          name: string
          organizer_entity_id?: string | null
          series_kind: string
          slug: string
          tenant_id?: string
          website_url?: string | null
        }
        Update: {
          id?: string
          kind?: string
          name?: string
          organizer_entity_id?: string | null
          series_kind?: string
          slug?: string
          tenant_id?: string
          website_url?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "event_series_id_fkey"
            columns: ["id"]
            isOneToOne: true
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "event_series_organizer_entity_id_fkey"
            columns: ["organizer_entity_id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "event_series_tenant_id_id_fkey"
            columns: ["tenant_id", "id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "event_series_tenant_id_id_kind_fkey"
            columns: ["tenant_id", "id", "kind"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id", "kind"]
          },
          {
            foreignKeyName: "event_series_tenant_id_organizer_entity_id_fkey"
            columns: ["tenant_id", "organizer_entity_id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      funding_round: {
        Row: {
          announced_on: string | null
          currency: string | null
          id: string
          kind: string
          round_kind: string | null
          tenant_id: string
        }
        Insert: {
          announced_on?: string | null
          currency?: string | null
          id: string
          kind?: string
          round_kind?: string | null
          tenant_id?: string
        }
        Update: {
          announced_on?: string | null
          currency?: string | null
          id?: string
          kind?: string
          round_kind?: string | null
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "funding_round_id_fkey"
            columns: ["id"]
            isOneToOne: true
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "funding_round_tenant_id_id_fkey"
            columns: ["tenant_id", "id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "funding_round_tenant_id_id_kind_fkey"
            columns: ["tenant_id", "id", "kind"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id", "kind"]
          },
        ]
      }
      industry_event: {
        Row: {
          city: string | null
          country: string | null
          edition_label: string | null
          ends_on: string | null
          event_kind: string
          format: string | null
          id: string
          kind: string
          name: string
          parent_event_id: string | null
          series_id: string | null
          slug: string
          starts_on: string | null
          tenant_id: string
          timezone: string | null
          venue: string | null
          website_url: string | null
        }
        Insert: {
          city?: string | null
          country?: string | null
          edition_label?: string | null
          ends_on?: string | null
          event_kind: string
          format?: string | null
          id: string
          kind?: string
          name: string
          parent_event_id?: string | null
          series_id?: string | null
          slug: string
          starts_on?: string | null
          tenant_id?: string
          timezone?: string | null
          venue?: string | null
          website_url?: string | null
        }
        Update: {
          city?: string | null
          country?: string | null
          edition_label?: string | null
          ends_on?: string | null
          event_kind?: string
          format?: string | null
          id?: string
          kind?: string
          name?: string
          parent_event_id?: string | null
          series_id?: string | null
          slug?: string
          starts_on?: string | null
          tenant_id?: string
          timezone?: string | null
          venue?: string | null
          website_url?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "industry_event_id_fkey"
            columns: ["id"]
            isOneToOne: true
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "industry_event_parent_event_id_fkey"
            columns: ["parent_event_id"]
            isOneToOne: false
            referencedRelation: "industry_event"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "industry_event_series_id_fkey"
            columns: ["series_id"]
            isOneToOne: false
            referencedRelation: "event_series"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "industry_event_tenant_id_id_fkey"
            columns: ["tenant_id", "id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "industry_event_tenant_id_id_kind_fkey"
            columns: ["tenant_id", "id", "kind"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id", "kind"]
          },
          {
            foreignKeyName: "industry_event_tenant_id_parent_event_id_fkey"
            columns: ["tenant_id", "parent_event_id"]
            isOneToOne: false
            referencedRelation: "industry_event"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "industry_event_tenant_id_series_id_fkey"
            columns: ["tenant_id", "series_id"]
            isOneToOne: false
            referencedRelation: "event_series"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      library: {
        Row: {
          description: string | null
          ecosystem: string | null
          id: string
          kind: string
          package_name: string | null
          tenant_id: string
        }
        Insert: {
          description?: string | null
          ecosystem?: string | null
          id: string
          kind?: string
          package_name?: string | null
          tenant_id?: string
        }
        Update: {
          description?: string | null
          ecosystem?: string | null
          id?: string
          kind?: string
          package_name?: string | null
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "library_id_fkey"
            columns: ["id"]
            isOneToOne: true
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "library_tenant_id_id_fkey"
            columns: ["tenant_id", "id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "library_tenant_id_id_kind_fkey"
            columns: ["tenant_id", "id", "kind"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id", "kind"]
          },
        ]
      }
      library_release: {
        Row: {
          id: string
          kind: string
          library_id: string
          license_code: string | null
          registry_id: string | null
          released_on: string | null
          source_revision_id: string | null
          tenant_id: string
          version_label: string
        }
        Insert: {
          id: string
          kind?: string
          library_id: string
          license_code?: string | null
          registry_id?: string | null
          released_on?: string | null
          source_revision_id?: string | null
          tenant_id?: string
          version_label: string
        }
        Update: {
          id?: string
          kind?: string
          library_id?: string
          license_code?: string | null
          registry_id?: string | null
          released_on?: string | null
          source_revision_id?: string | null
          tenant_id?: string
          version_label?: string
        }
        Relationships: [
          {
            foreignKeyName: "library_release_id_fkey"
            columns: ["id"]
            isOneToOne: true
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "library_release_library_id_fkey"
            columns: ["library_id"]
            isOneToOne: false
            referencedRelation: "library"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "library_release_license_code_fkey"
            columns: ["license_code"]
            isOneToOne: false
            referencedRelation: "license"
            referencedColumns: ["code"]
          },
          {
            foreignKeyName: "library_release_registry_id_fkey"
            columns: ["registry_id"]
            isOneToOne: false
            referencedRelation: "registry"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "library_release_source_revision_id_fkey"
            columns: ["source_revision_id"]
            isOneToOne: false
            referencedRelation: "repository_revision"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "library_release_tenant_id_id_fkey"
            columns: ["tenant_id", "id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "library_release_tenant_id_id_kind_fkey"
            columns: ["tenant_id", "id", "kind"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id", "kind"]
          },
          {
            foreignKeyName: "library_release_tenant_id_library_id_fkey"
            columns: ["tenant_id", "library_id"]
            isOneToOne: false
            referencedRelation: "library"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "library_release_tenant_id_registry_id_fkey"
            columns: ["tenant_id", "registry_id"]
            isOneToOne: false
            referencedRelation: "registry"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "library_release_tenant_id_source_revision_id_fkey"
            columns: ["tenant_id", "source_revision_id"]
            isOneToOne: false
            referencedRelation: "repository_revision"
            referencedColumns: ["tenant_id", "id"]
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
      mcp_server: {
        Row: {
          description: string | null
          id: string
          kind: string
          tenant_id: string
          transport: string[] | null
        }
        Insert: {
          description?: string | null
          id: string
          kind?: string
          tenant_id?: string
          transport?: string[] | null
        }
        Update: {
          description?: string | null
          id?: string
          kind?: string
          tenant_id?: string
          transport?: string[] | null
        }
        Relationships: [
          {
            foreignKeyName: "mcp_server_id_fkey"
            columns: ["id"]
            isOneToOne: true
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "mcp_server_tenant_id_id_fkey"
            columns: ["tenant_id", "id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "mcp_server_tenant_id_id_kind_fkey"
            columns: ["tenant_id", "id", "kind"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id", "kind"]
          },
        ]
      }
      mcp_server_surface: {
        Row: {
          id: string
          name: string
          schema_artifact_id: string | null
          server_id: string
          surface_kind: string
          tenant_id: string
        }
        Insert: {
          id?: string
          name: string
          schema_artifact_id?: string | null
          server_id: string
          surface_kind: string
          tenant_id?: string
        }
        Update: {
          id?: string
          name?: string
          schema_artifact_id?: string | null
          server_id?: string
          surface_kind?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "mcp_server_surface_server_id_fkey"
            columns: ["server_id"]
            isOneToOne: false
            referencedRelation: "mcp_server"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "mcp_server_surface_tenant_id_server_id_fkey"
            columns: ["tenant_id", "server_id"]
            isOneToOne: false
            referencedRelation: "mcp_server"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      media_appearance: {
        Row: {
          confidence: number | null
          created_at: string
          end_ms: number | null
          entity_id: string
          id: string
          locator_id: string | null
          media_work_id: string
          method: string
          primary_claim_id: string | null
          role: string
          start_ms: number | null
          tenant_id: string
        }
        Insert: {
          confidence?: number | null
          created_at?: string
          end_ms?: number | null
          entity_id: string
          id?: string
          locator_id?: string | null
          media_work_id: string
          method: string
          primary_claim_id?: string | null
          role: string
          start_ms?: number | null
          tenant_id?: string
        }
        Update: {
          confidence?: number | null
          created_at?: string
          end_ms?: number | null
          entity_id?: string
          id?: string
          locator_id?: string | null
          media_work_id?: string
          method?: string
          primary_claim_id?: string | null
          role?: string
          start_ms?: number | null
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "media_appearance_entity_id_fkey"
            columns: ["entity_id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "media_appearance_media_work_id_fkey"
            columns: ["media_work_id"]
            isOneToOne: false
            referencedRelation: "media_work"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "media_appearance_tenant_id_entity_id_fkey"
            columns: ["tenant_id", "entity_id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "media_appearance_tenant_id_media_work_id_fkey"
            columns: ["tenant_id", "media_work_id"]
            isOneToOne: false
            referencedRelation: "media_work"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      media_channel: {
        Row: {
          created_at_platform: string | null
          external_id: string
          handle: string | null
          id: string
          kind: string
          owner_entity_id: string | null
          platform_code: string
          tenant_id: string
          title: string
          url: string | null
        }
        Insert: {
          created_at_platform?: string | null
          external_id: string
          handle?: string | null
          id: string
          kind?: string
          owner_entity_id?: string | null
          platform_code: string
          tenant_id?: string
          title: string
          url?: string | null
        }
        Update: {
          created_at_platform?: string | null
          external_id?: string
          handle?: string | null
          id?: string
          kind?: string
          owner_entity_id?: string | null
          platform_code?: string
          tenant_id?: string
          title?: string
          url?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "media_channel_id_fkey"
            columns: ["id"]
            isOneToOne: true
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "media_channel_owner_entity_id_fkey"
            columns: ["owner_entity_id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "media_channel_platform_code_fkey"
            columns: ["platform_code"]
            isOneToOne: false
            referencedRelation: "media_platform"
            referencedColumns: ["code"]
          },
          {
            foreignKeyName: "media_channel_tenant_id_id_fkey"
            columns: ["tenant_id", "id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "media_channel_tenant_id_id_kind_fkey"
            columns: ["tenant_id", "id", "kind"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id", "kind"]
          },
          {
            foreignKeyName: "media_channel_tenant_id_owner_entity_id_fkey"
            columns: ["tenant_id", "owner_entity_id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
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
      media_series: {
        Row: {
          description: string | null
          external_id: string | null
          id: string
          industry_event_id: string | null
          kind: string
          platform_code: string | null
          primary_channel_id: string | null
          series_kind: string
          tenant_id: string
          title: string
        }
        Insert: {
          description?: string | null
          external_id?: string | null
          id: string
          industry_event_id?: string | null
          kind?: string
          platform_code?: string | null
          primary_channel_id?: string | null
          series_kind: string
          tenant_id?: string
          title: string
        }
        Update: {
          description?: string | null
          external_id?: string | null
          id?: string
          industry_event_id?: string | null
          kind?: string
          platform_code?: string | null
          primary_channel_id?: string | null
          series_kind?: string
          tenant_id?: string
          title?: string
        }
        Relationships: [
          {
            foreignKeyName: "media_series_id_fkey"
            columns: ["id"]
            isOneToOne: true
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "media_series_industry_event_id_fkey"
            columns: ["industry_event_id"]
            isOneToOne: false
            referencedRelation: "industry_event"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "media_series_platform_code_fkey"
            columns: ["platform_code"]
            isOneToOne: false
            referencedRelation: "media_platform"
            referencedColumns: ["code"]
          },
          {
            foreignKeyName: "media_series_primary_channel_id_fkey"
            columns: ["primary_channel_id"]
            isOneToOne: false
            referencedRelation: "media_channel"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "media_series_tenant_id_id_fkey"
            columns: ["tenant_id", "id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "media_series_tenant_id_id_kind_fkey"
            columns: ["tenant_id", "id", "kind"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id", "kind"]
          },
          {
            foreignKeyName: "media_series_tenant_id_industry_event_id_fkey"
            columns: ["tenant_id", "industry_event_id"]
            isOneToOne: false
            referencedRelation: "industry_event"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "media_series_tenant_id_primary_channel_id_fkey"
            columns: ["tenant_id", "primary_channel_id"]
            isOneToOne: false
            referencedRelation: "media_channel"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      media_work: {
        Row: {
          channel_id: string | null
          duration_ms: number | null
          external_id: string | null
          height: number | null
          id: string
          kind: string
          language: string | null
          media_kind: string
          platform_code: string
          published_at: string | null
          tenant_id: string
          title: string
          url: string | null
          width: number | null
        }
        Insert: {
          channel_id?: string | null
          duration_ms?: number | null
          external_id?: string | null
          height?: number | null
          id: string
          kind?: string
          language?: string | null
          media_kind: string
          platform_code: string
          published_at?: string | null
          tenant_id?: string
          title: string
          url?: string | null
          width?: number | null
        }
        Update: {
          channel_id?: string | null
          duration_ms?: number | null
          external_id?: string | null
          height?: number | null
          id?: string
          kind?: string
          language?: string | null
          media_kind?: string
          platform_code?: string
          published_at?: string | null
          tenant_id?: string
          title?: string
          url?: string | null
          width?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "media_work_channel_id_fkey"
            columns: ["channel_id"]
            isOneToOne: false
            referencedRelation: "media_channel"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "media_work_id_fkey"
            columns: ["id"]
            isOneToOne: true
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "media_work_platform_code_fkey"
            columns: ["platform_code"]
            isOneToOne: false
            referencedRelation: "media_platform"
            referencedColumns: ["code"]
          },
          {
            foreignKeyName: "media_work_tenant_id_channel_id_fkey"
            columns: ["tenant_id", "channel_id"]
            isOneToOne: false
            referencedRelation: "media_channel"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "media_work_tenant_id_id_fkey"
            columns: ["tenant_id", "id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "media_work_tenant_id_id_kind_fkey"
            columns: ["tenant_id", "id", "kind"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id", "kind"]
          },
        ]
      }
      model_offering: {
        Row: {
          id: string
          kind: string
          model_version_id: string
          offering_key: string
          provider_entity_id: string
          tenant_id: string
        }
        Insert: {
          id: string
          kind?: string
          model_version_id: string
          offering_key: string
          provider_entity_id: string
          tenant_id?: string
        }
        Update: {
          id?: string
          kind?: string
          model_version_id?: string
          offering_key?: string
          provider_entity_id?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "model_offering_id_fkey"
            columns: ["id"]
            isOneToOne: true
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "model_offering_model_version_id_fkey"
            columns: ["model_version_id"]
            isOneToOne: false
            referencedRelation: "ai_model_version"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "model_offering_provider_entity_id_fkey"
            columns: ["provider_entity_id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "model_offering_tenant_id_id_fkey"
            columns: ["tenant_id", "id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "model_offering_tenant_id_id_kind_fkey"
            columns: ["tenant_id", "id", "kind"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id", "kind"]
          },
          {
            foreignKeyName: "model_offering_tenant_id_model_version_id_fkey"
            columns: ["tenant_id", "model_version_id"]
            isOneToOne: false
            referencedRelation: "ai_model_version"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "model_offering_tenant_id_provider_entity_id_fkey"
            columns: ["tenant_id", "provider_entity_id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      organization: {
        Row: {
          country_code: string | null
          founded_on: string | null
          id: string
          kind: string
          legal_name: string | null
          tenant_id: string
          website_url: string | null
        }
        Insert: {
          country_code?: string | null
          founded_on?: string | null
          id: string
          kind?: string
          legal_name?: string | null
          tenant_id?: string
          website_url?: string | null
        }
        Update: {
          country_code?: string | null
          founded_on?: string | null
          id?: string
          kind?: string
          legal_name?: string | null
          tenant_id?: string
          website_url?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "organization_id_fkey"
            columns: ["id"]
            isOneToOne: true
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "organization_tenant_id_id_fkey"
            columns: ["tenant_id", "id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "organization_tenant_id_id_kind_fkey"
            columns: ["tenant_id", "id", "kind"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id", "kind"]
          },
        ]
      }
      paper: {
        Row: {
          abstract: string | null
          arxiv_id: string | null
          doi: string | null
          id: string
          kind: string
          published_on: string | null
          tenant_id: string
          title: string
        }
        Insert: {
          abstract?: string | null
          arxiv_id?: string | null
          doi?: string | null
          id: string
          kind?: string
          published_on?: string | null
          tenant_id?: string
          title: string
        }
        Update: {
          abstract?: string | null
          arxiv_id?: string | null
          doi?: string | null
          id?: string
          kind?: string
          published_on?: string | null
          tenant_id?: string
          title?: string
        }
        Relationships: [
          {
            foreignKeyName: "paper_id_fkey"
            columns: ["id"]
            isOneToOne: true
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "paper_tenant_id_id_fkey"
            columns: ["tenant_id", "id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "paper_tenant_id_id_kind_fkey"
            columns: ["tenant_id", "id", "kind"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id", "kind"]
          },
        ]
      }
      person: {
        Row: {
          family_name: string | null
          given_name: string | null
          id: string
          kind: string
          orcid: string | null
          tenant_id: string
        }
        Insert: {
          family_name?: string | null
          given_name?: string | null
          id: string
          kind?: string
          orcid?: string | null
          tenant_id?: string
        }
        Update: {
          family_name?: string | null
          given_name?: string | null
          id?: string
          kind?: string
          orcid?: string | null
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "person_id_fkey"
            columns: ["id"]
            isOneToOne: true
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "person_tenant_id_id_fkey"
            columns: ["tenant_id", "id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "person_tenant_id_id_kind_fkey"
            columns: ["tenant_id", "id", "kind"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id", "kind"]
          },
        ]
      }
      product: {
        Row: {
          id: string
          kind: string
          product_kind: string | null
          tenant_id: string
          website_url: string | null
        }
        Insert: {
          id: string
          kind?: string
          product_kind?: string | null
          tenant_id?: string
          website_url?: string | null
        }
        Update: {
          id?: string
          kind?: string
          product_kind?: string | null
          tenant_id?: string
          website_url?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "product_id_fkey"
            columns: ["id"]
            isOneToOne: true
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "product_tenant_id_id_fkey"
            columns: ["tenant_id", "id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "product_tenant_id_id_kind_fkey"
            columns: ["tenant_id", "id", "kind"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id", "kind"]
          },
        ]
      }
      product_feature: {
        Row: {
          description: string | null
          feature_key: string
          id: string
          kind: string
          product_id: string
          tenant_id: string
        }
        Insert: {
          description?: string | null
          feature_key: string
          id: string
          kind?: string
          product_id: string
          tenant_id?: string
        }
        Update: {
          description?: string | null
          feature_key?: string
          id?: string
          kind?: string
          product_id?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "product_feature_id_fkey"
            columns: ["id"]
            isOneToOne: true
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "product_feature_product_id_fkey"
            columns: ["product_id"]
            isOneToOne: false
            referencedRelation: "product"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "product_feature_tenant_id_id_fkey"
            columns: ["tenant_id", "id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "product_feature_tenant_id_id_kind_fkey"
            columns: ["tenant_id", "id", "kind"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id", "kind"]
          },
          {
            foreignKeyName: "product_feature_tenant_id_product_id_fkey"
            columns: ["tenant_id", "product_id"]
            isOneToOne: false
            referencedRelation: "product"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      product_version: {
        Row: {
          id: string
          kind: string
          product_id: string
          tenant_id: string
          version_label: string
        }
        Insert: {
          id: string
          kind?: string
          product_id: string
          tenant_id?: string
          version_label: string
        }
        Update: {
          id?: string
          kind?: string
          product_id?: string
          tenant_id?: string
          version_label?: string
        }
        Relationships: [
          {
            foreignKeyName: "product_version_id_fkey"
            columns: ["id"]
            isOneToOne: true
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "product_version_product_id_fkey"
            columns: ["product_id"]
            isOneToOne: false
            referencedRelation: "product"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "product_version_tenant_id_id_fkey"
            columns: ["tenant_id", "id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "product_version_tenant_id_id_kind_fkey"
            columns: ["tenant_id", "id", "kind"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id", "kind"]
          },
          {
            foreignKeyName: "product_version_tenant_id_product_id_fkey"
            columns: ["tenant_id", "product_id"]
            isOneToOne: false
            referencedRelation: "product"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      registry: {
        Row: {
          canonical_url: string | null
          id: string
          kind: string
          registry_kind: string | null
          tenant_id: string
        }
        Insert: {
          canonical_url?: string | null
          id: string
          kind?: string
          registry_kind?: string | null
          tenant_id?: string
        }
        Update: {
          canonical_url?: string | null
          id?: string
          kind?: string
          registry_kind?: string | null
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "registry_id_fkey"
            columns: ["id"]
            isOneToOne: true
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "registry_tenant_id_id_fkey"
            columns: ["tenant_id", "id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "registry_tenant_id_id_kind_fkey"
            columns: ["tenant_id", "id", "kind"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id", "kind"]
          },
        ]
      }
      registry_listing: {
        Row: {
          canonical_url: string | null
          entity_id: string
          external_id: string
          id: string
          registry_id: string
          tenant_id: string
        }
        Insert: {
          canonical_url?: string | null
          entity_id: string
          external_id: string
          id?: string
          registry_id: string
          tenant_id?: string
        }
        Update: {
          canonical_url?: string | null
          entity_id?: string
          external_id?: string
          id?: string
          registry_id?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "registry_listing_entity_id_fkey"
            columns: ["entity_id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "registry_listing_registry_id_fkey"
            columns: ["registry_id"]
            isOneToOne: false
            referencedRelation: "registry"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "registry_listing_tenant_id_entity_id_fkey"
            columns: ["tenant_id", "entity_id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "registry_listing_tenant_id_registry_id_fkey"
            columns: ["tenant_id", "registry_id"]
            isOneToOne: false
            referencedRelation: "registry"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      relationship: {
        Row: {
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
      repository: {
        Row: {
          created_at_host: string | null
          fork_of_repository_id: string | null
          host: string
          id: string
          is_fork: boolean
          kind: string
          name: string
          owner: string
          provider_native_id: string | null
          tenant_id: string
        }
        Insert: {
          created_at_host?: string | null
          fork_of_repository_id?: string | null
          host: string
          id: string
          is_fork?: boolean
          kind?: string
          name: string
          owner: string
          provider_native_id?: string | null
          tenant_id?: string
        }
        Update: {
          created_at_host?: string | null
          fork_of_repository_id?: string | null
          host?: string
          id?: string
          is_fork?: boolean
          kind?: string
          name?: string
          owner?: string
          provider_native_id?: string | null
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "repository_fork_of_repository_id_fkey"
            columns: ["fork_of_repository_id"]
            isOneToOne: false
            referencedRelation: "repository"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "repository_id_fkey"
            columns: ["id"]
            isOneToOne: true
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "repository_tenant_id_fork_of_repository_id_fkey"
            columns: ["tenant_id", "fork_of_repository_id"]
            isOneToOne: false
            referencedRelation: "repository"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "repository_tenant_id_id_fkey"
            columns: ["tenant_id", "id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "repository_tenant_id_id_kind_fkey"
            columns: ["tenant_id", "id", "kind"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id", "kind"]
          },
        ]
      }
      repository_file: {
        Row: {
          blob_sha: string | null
          capture_id: string | null
          created_at: string
          file_role: string
          id: string
          language: string | null
          module_id: string | null
          path: string
          repository_id: string
          revision_id: string
          size_bytes: number | null
          tenant_id: string
        }
        Insert: {
          blob_sha?: string | null
          capture_id?: string | null
          created_at?: string
          file_role: string
          id?: string
          language?: string | null
          module_id?: string | null
          path: string
          repository_id: string
          revision_id: string
          size_bytes?: number | null
          tenant_id?: string
        }
        Update: {
          blob_sha?: string | null
          capture_id?: string | null
          created_at?: string
          file_role?: string
          id?: string
          language?: string | null
          module_id?: string | null
          path?: string
          repository_id?: string
          revision_id?: string
          size_bytes?: number | null
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "repository_file_module_id_fkey"
            columns: ["module_id"]
            isOneToOne: false
            referencedRelation: "repository_module"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "repository_file_repository_id_fkey"
            columns: ["repository_id"]
            isOneToOne: false
            referencedRelation: "repository"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "repository_file_revision_id_fkey"
            columns: ["revision_id"]
            isOneToOne: false
            referencedRelation: "repository_revision"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "repository_file_tenant_id_module_id_fkey"
            columns: ["tenant_id", "module_id"]
            isOneToOne: false
            referencedRelation: "repository_module"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "repository_file_tenant_id_repository_id_fkey"
            columns: ["tenant_id", "repository_id"]
            isOneToOne: false
            referencedRelation: "repository"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "repository_file_tenant_id_revision_id_fkey"
            columns: ["tenant_id", "revision_id"]
            isOneToOne: false
            referencedRelation: "repository_revision"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      repository_module: {
        Row: {
          description: string | null
          first_seen_revision_id: string | null
          id: string
          language: string | null
          last_seen_revision_id: string | null
          library_id: string | null
          manifest_kind: string | null
          manifest_path: string | null
          module_kind: string
          name: string | null
          path: string
          repository_id: string
          tenant_id: string
        }
        Insert: {
          description?: string | null
          first_seen_revision_id?: string | null
          id?: string
          language?: string | null
          last_seen_revision_id?: string | null
          library_id?: string | null
          manifest_kind?: string | null
          manifest_path?: string | null
          module_kind: string
          name?: string | null
          path: string
          repository_id: string
          tenant_id?: string
        }
        Update: {
          description?: string | null
          first_seen_revision_id?: string | null
          id?: string
          language?: string | null
          last_seen_revision_id?: string | null
          library_id?: string | null
          manifest_kind?: string | null
          manifest_path?: string | null
          module_kind?: string
          name?: string | null
          path?: string
          repository_id?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "repository_module_first_seen_revision_id_fkey"
            columns: ["first_seen_revision_id"]
            isOneToOne: false
            referencedRelation: "repository_revision"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "repository_module_last_seen_revision_id_fkey"
            columns: ["last_seen_revision_id"]
            isOneToOne: false
            referencedRelation: "repository_revision"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "repository_module_library_id_fkey"
            columns: ["library_id"]
            isOneToOne: false
            referencedRelation: "library"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "repository_module_repository_id_fkey"
            columns: ["repository_id"]
            isOneToOne: false
            referencedRelation: "repository"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "repository_module_tenant_id_first_seen_revision_id_fkey"
            columns: ["tenant_id", "first_seen_revision_id"]
            isOneToOne: false
            referencedRelation: "repository_revision"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "repository_module_tenant_id_last_seen_revision_id_fkey"
            columns: ["tenant_id", "last_seen_revision_id"]
            isOneToOne: false
            referencedRelation: "repository_revision"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "repository_module_tenant_id_library_id_fkey"
            columns: ["tenant_id", "library_id"]
            isOneToOne: false
            referencedRelation: "library"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "repository_module_tenant_id_repository_id_fkey"
            columns: ["tenant_id", "repository_id"]
            isOneToOne: false
            referencedRelation: "repository"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      repository_revision: {
        Row: {
          capture_id: string | null
          commit_sha: string
          committed_at: string | null
          created_at: string
          file_count: number | null
          id: string
          languages: Json
          manifest_truncated: boolean
          ref_name: string | null
          repository_id: string
          tenant_id: string
          total_bytes: number | null
          tree_manifest_artifact_id: string | null
          tree_sha: string | null
        }
        Insert: {
          capture_id?: string | null
          commit_sha: string
          committed_at?: string | null
          created_at?: string
          file_count?: number | null
          id?: string
          languages?: Json
          manifest_truncated?: boolean
          ref_name?: string | null
          repository_id: string
          tenant_id?: string
          total_bytes?: number | null
          tree_manifest_artifact_id?: string | null
          tree_sha?: string | null
        }
        Update: {
          capture_id?: string | null
          commit_sha?: string
          committed_at?: string | null
          created_at?: string
          file_count?: number | null
          id?: string
          languages?: Json
          manifest_truncated?: boolean
          ref_name?: string | null
          repository_id?: string
          tenant_id?: string
          total_bytes?: number | null
          tree_manifest_artifact_id?: string | null
          tree_sha?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "repository_revision_repository_id_fkey"
            columns: ["repository_id"]
            isOneToOne: false
            referencedRelation: "repository"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "repository_revision_tenant_id_repository_id_fkey"
            columns: ["tenant_id", "repository_id"]
            isOneToOne: false
            referencedRelation: "repository"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      security_advisory: {
        Row: {
          advisory_id: string
          canonical_url: string | null
          description: string | null
          ecosystem: string | null
          id: string
          kind: string
          tenant_id: string
        }
        Insert: {
          advisory_id: string
          canonical_url?: string | null
          description?: string | null
          ecosystem?: string | null
          id: string
          kind?: string
          tenant_id?: string
        }
        Update: {
          advisory_id?: string
          canonical_url?: string | null
          description?: string | null
          ecosystem?: string | null
          id?: string
          kind?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "security_advisory_id_fkey"
            columns: ["id"]
            isOneToOne: true
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "security_advisory_tenant_id_id_fkey"
            columns: ["tenant_id", "id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "security_advisory_tenant_id_id_kind_fkey"
            columns: ["tenant_id", "id", "kind"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id", "kind"]
          },
        ]
      }
      story: {
        Row: {
          canonical_url: string | null
          id: string
          kind: string
          published_at: string | null
          tenant_id: string
          title: string
        }
        Insert: {
          canonical_url?: string | null
          id: string
          kind?: string
          published_at?: string | null
          tenant_id?: string
          title: string
        }
        Update: {
          canonical_url?: string | null
          id?: string
          kind?: string
          published_at?: string | null
          tenant_id?: string
          title?: string
        }
        Relationships: [
          {
            foreignKeyName: "story_id_fkey"
            columns: ["id"]
            isOneToOne: true
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "story_tenant_id_id_fkey"
            columns: ["tenant_id", "id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "story_tenant_id_id_kind_fkey"
            columns: ["tenant_id", "id", "kind"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id", "kind"]
          },
        ]
      }
      talk: {
        Row: {
          abstract: string | null
          delivered_on: string | null
          duration_minutes: number | null
          id: string
          kind: string
          language: string | null
          talk_kind: string
          tenant_id: string
          title: string
        }
        Insert: {
          abstract?: string | null
          delivered_on?: string | null
          duration_minutes?: number | null
          id: string
          kind?: string
          language?: string | null
          talk_kind?: string
          tenant_id?: string
          title: string
        }
        Update: {
          abstract?: string | null
          delivered_on?: string | null
          duration_minutes?: number | null
          id?: string
          kind?: string
          language?: string | null
          talk_kind?: string
          tenant_id?: string
          title?: string
        }
        Relationships: [
          {
            foreignKeyName: "talk_id_fkey"
            columns: ["id"]
            isOneToOne: true
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "talk_tenant_id_id_fkey"
            columns: ["tenant_id", "id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "talk_tenant_id_id_kind_fkey"
            columns: ["tenant_id", "id", "kind"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id", "kind"]
          },
        ]
      }
      technique: {
        Row: {
          description: string | null
          id: string
          kind: string
          technique_kind: string | null
          tenant_id: string
        }
        Insert: {
          description?: string | null
          id: string
          kind?: string
          technique_kind?: string | null
          tenant_id?: string
        }
        Update: {
          description?: string | null
          id?: string
          kind?: string
          technique_kind?: string | null
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "technique_id_fkey"
            columns: ["id"]
            isOneToOne: true
            referencedRelation: "entity"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "technique_tenant_id_id_fkey"
            columns: ["tenant_id", "id"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "technique_tenant_id_id_kind_fkey"
            columns: ["tenant_id", "id", "kind"]
            isOneToOne: false
            referencedRelation: "entity"
            referencedColumns: ["tenant_id", "id", "kind"]
          },
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      import_research_starter_catalog: {
        Args: { p_receipt: string }
        Returns: Json
      }
      rebuild_entity_projections: { Args: { p_k?: number }; Returns: number }
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
          metric_definition_version_id: string | null
          mission_id: string | null
          policy_artifact_id: string | null
          ranking_policy_version_id: string | null
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
          metric_definition_version_id?: string | null
          mission_id?: string | null
          policy_artifact_id?: string | null
          ranking_policy_version_id?: string | null
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
          metric_definition_version_id?: string | null
          mission_id?: string | null
          policy_artifact_id?: string | null
          ranking_policy_version_id?: string | null
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
          ranking_result_id: string | null
          record_reconciliation_id: string | null
          report_version_id: string | null
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
          ranking_result_id?: string | null
          record_reconciliation_id?: string | null
          report_version_id?: string | null
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
          ranking_result_id?: string | null
          record_reconciliation_id?: string | null
          report_version_id?: string | null
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
          extraction_run_id: string
          id: string
          locator_id: string | null
          payload: Json
          record_kind: string
          tenant_id: string
        }
        Insert: {
          claim_id?: string | null
          confidence?: number | null
          created_at?: string
          extraction_run_id: string
          id?: string
          locator_id?: string | null
          payload: Json
          record_kind: string
          tenant_id?: string
        }
        Update: {
          claim_id?: string | null
          confidence?: number | null
          created_at?: string
          extraction_run_id?: string
          id?: string
          locator_id?: string | null
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
      source_capture: {
        Row: {
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
  knowledge: {
    Tables: {
      advanced_usage_pattern: {
        Row: {
          id: string
          kind: string
          prerequisites: string[] | null
          tenant_id: string
          usage: string | null
        }
        Insert: {
          id: string
          kind?: string
          prerequisites?: string[] | null
          tenant_id?: string
          usage?: string | null
        }
        Update: {
          id?: string
          kind?: string
          prerequisites?: string[] | null
          tenant_id?: string
          usage?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "advanced_usage_pattern_id_fkey"
            columns: ["id"]
            isOneToOne: true
            referencedRelation: "record"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "advanced_usage_pattern_tenant_id_id_fkey"
            columns: ["tenant_id", "id"]
            isOneToOne: false
            referencedRelation: "record"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "advanced_usage_pattern_tenant_id_id_kind_fkey"
            columns: ["tenant_id", "id", "kind"]
            isOneToOne: false
            referencedRelation: "record"
            referencedColumns: ["tenant_id", "id", "kind"]
          },
        ]
      }
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
      benchmark_result: {
        Row: {
          benchmark_run_id: string | null
          id: string
          kind: string
          metric_name: string | null
          tenant_id: string
          unit: string | null
          value: number | null
        }
        Insert: {
          benchmark_run_id?: string | null
          id: string
          kind?: string
          metric_name?: string | null
          tenant_id?: string
          unit?: string | null
          value?: number | null
        }
        Update: {
          benchmark_run_id?: string | null
          id?: string
          kind?: string
          metric_name?: string | null
          tenant_id?: string
          unit?: string | null
          value?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "benchmark_result_id_fkey"
            columns: ["id"]
            isOneToOne: true
            referencedRelation: "record"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "benchmark_result_tenant_id_id_fkey"
            columns: ["tenant_id", "id"]
            isOneToOne: false
            referencedRelation: "record"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "benchmark_result_tenant_id_id_kind_fkey"
            columns: ["tenant_id", "id", "kind"]
            isOneToOne: false
            referencedRelation: "record"
            referencedColumns: ["tenant_id", "id", "kind"]
          },
        ]
      }
      compatibility_constraint: {
        Row: {
          constraint_kind: string | null
          expression: string | null
          id: string
          kind: string
          tenant_id: string
        }
        Insert: {
          constraint_kind?: string | null
          expression?: string | null
          id: string
          kind?: string
          tenant_id?: string
        }
        Update: {
          constraint_kind?: string | null
          expression?: string | null
          id?: string
          kind?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "compatibility_constraint_id_fkey"
            columns: ["id"]
            isOneToOne: true
            referencedRelation: "record"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "compatibility_constraint_tenant_id_id_fkey"
            columns: ["tenant_id", "id"]
            isOneToOne: false
            referencedRelation: "record"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "compatibility_constraint_tenant_id_id_kind_fkey"
            columns: ["tenant_id", "id", "kind"]
            isOneToOne: false
            referencedRelation: "record"
            referencedColumns: ["tenant_id", "id", "kind"]
          },
        ]
      }
      failure_mode: {
        Row: {
          failure_class: string | null
          id: string
          kind: string
          mitigations: string | null
          tenant_id: string
          trigger_conditions: string | null
        }
        Insert: {
          failure_class?: string | null
          id: string
          kind?: string
          mitigations?: string | null
          tenant_id?: string
          trigger_conditions?: string | null
        }
        Update: {
          failure_class?: string | null
          id?: string
          kind?: string
          mitigations?: string | null
          tenant_id?: string
          trigger_conditions?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "failure_mode_id_fkey"
            columns: ["id"]
            isOneToOne: true
            referencedRelation: "record"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "failure_mode_tenant_id_id_fkey"
            columns: ["tenant_id", "id"]
            isOneToOne: false
            referencedRelation: "record"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "failure_mode_tenant_id_id_kind_fkey"
            columns: ["tenant_id", "id", "kind"]
            isOneToOne: false
            referencedRelation: "record"
            referencedColumns: ["tenant_id", "id", "kind"]
          },
        ]
      }
      implementation_example: {
        Row: {
          end_line: number | null
          id: string
          kind: string
          repository_file_id: string | null
          start_line: number | null
          symbol: string | null
          tenant_id: string
        }
        Insert: {
          end_line?: number | null
          id: string
          kind?: string
          repository_file_id?: string | null
          start_line?: number | null
          symbol?: string | null
          tenant_id?: string
        }
        Update: {
          end_line?: number | null
          id?: string
          kind?: string
          repository_file_id?: string | null
          start_line?: number | null
          symbol?: string | null
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "implementation_example_id_fkey"
            columns: ["id"]
            isOneToOne: true
            referencedRelation: "record"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "implementation_example_tenant_id_id_fkey"
            columns: ["tenant_id", "id"]
            isOneToOne: false
            referencedRelation: "record"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "implementation_example_tenant_id_id_kind_fkey"
            columns: ["tenant_id", "id", "kind"]
            isOneToOne: false
            referencedRelation: "record"
            referencedColumns: ["tenant_id", "id", "kind"]
          },
        ]
      }
      operational_practice: {
        Row: {
          id: string
          kind: string
          practice_kind: string | null
          procedure: string | null
          tenant_id: string
        }
        Insert: {
          id: string
          kind?: string
          practice_kind?: string | null
          procedure?: string | null
          tenant_id?: string
        }
        Update: {
          id?: string
          kind?: string
          practice_kind?: string | null
          procedure?: string | null
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "operational_practice_id_fkey"
            columns: ["id"]
            isOneToOne: true
            referencedRelation: "record"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "operational_practice_tenant_id_id_fkey"
            columns: ["tenant_id", "id"]
            isOneToOne: false
            referencedRelation: "record"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "operational_practice_tenant_id_id_kind_fkey"
            columns: ["tenant_id", "id", "kind"]
            isOneToOne: false
            referencedRelation: "record"
            referencedColumns: ["tenant_id", "id", "kind"]
          },
        ]
      }
      record: {
        Row: {
          assurance_level: string
          created_at: string
          created_by_receipt_id: string
          id: string
          kind: string
          provenance_claim_id: string | null
          scope: Json
          statement: string
          tenant_id: string
          title: string
        }
        Insert: {
          assurance_level?: string
          created_at?: string
          created_by_receipt_id: string
          id?: string
          kind: string
          provenance_claim_id?: string | null
          scope?: Json
          statement: string
          tenant_id?: string
          title: string
        }
        Update: {
          assurance_level?: string
          created_at?: string
          created_by_receipt_id?: string
          id?: string
          kind?: string
          provenance_claim_id?: string | null
          scope?: Json
          statement?: string
          tenant_id?: string
          title?: string
        }
        Relationships: [
          {
            foreignKeyName: "record_assurance_level_fkey"
            columns: ["assurance_level"]
            isOneToOne: false
            referencedRelation: "assurance_level"
            referencedColumns: ["code"]
          },
        ]
      }
      record_entity_link: {
        Row: {
          entity_id: string
          record_id: string
          role: string
          tenant_id: string
        }
        Insert: {
          entity_id: string
          record_id: string
          role: string
          tenant_id?: string
        }
        Update: {
          entity_id?: string
          record_id?: string
          role?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "record_entity_link_record_id_fkey"
            columns: ["record_id"]
            isOneToOne: false
            referencedRelation: "record"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "record_entity_link_tenant_id_record_id_fkey"
            columns: ["tenant_id", "record_id"]
            isOneToOne: false
            referencedRelation: "record"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      record_reconciliation: {
        Row: {
          created_at: string
          created_by_receipt_id: string
          id: string
          merged_id: string
          outcome: string
          rationale: string
          record_kind: string
          surviving_id: string
        }
        Insert: {
          created_at?: string
          created_by_receipt_id: string
          id?: string
          merged_id: string
          outcome: string
          rationale: string
          record_kind: string
          surviving_id: string
        }
        Update: {
          created_at?: string
          created_by_receipt_id?: string
          id?: string
          merged_id?: string
          outcome?: string
          rationale?: string
          record_kind?: string
          surviving_id?: string
        }
        Relationships: []
      }
      security_consideration: {
        Row: {
          id: string
          kind: string
          mitigation: string | null
          severity: string | null
          tenant_id: string
          threat: string | null
        }
        Insert: {
          id: string
          kind?: string
          mitigation?: string | null
          severity?: string | null
          tenant_id?: string
          threat?: string | null
        }
        Update: {
          id?: string
          kind?: string
          mitigation?: string | null
          severity?: string | null
          tenant_id?: string
          threat?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "security_consideration_id_fkey"
            columns: ["id"]
            isOneToOne: true
            referencedRelation: "record"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "security_consideration_tenant_id_id_fkey"
            columns: ["tenant_id", "id"]
            isOneToOne: false
            referencedRelation: "record"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "security_consideration_tenant_id_id_kind_fkey"
            columns: ["tenant_id", "id", "kind"]
            isOneToOne: false
            referencedRelation: "record"
            referencedColumns: ["tenant_id", "id", "kind"]
          },
        ]
      }
      solution_pattern: {
        Row: {
          id: string
          kind: string
          mechanism: string | null
          pattern_kind: string | null
          tenant_id: string
          tradeoffs: string | null
        }
        Insert: {
          id: string
          kind?: string
          mechanism?: string | null
          pattern_kind?: string | null
          tenant_id?: string
          tradeoffs?: string | null
        }
        Update: {
          id?: string
          kind?: string
          mechanism?: string | null
          pattern_kind?: string | null
          tenant_id?: string
          tradeoffs?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "solution_pattern_id_fkey"
            columns: ["id"]
            isOneToOne: true
            referencedRelation: "record"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "solution_pattern_tenant_id_id_fkey"
            columns: ["tenant_id", "id"]
            isOneToOne: false
            referencedRelation: "record"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "solution_pattern_tenant_id_id_kind_fkey"
            columns: ["tenant_id", "id", "kind"]
            isOneToOne: false
            referencedRelation: "record"
            referencedColumns: ["tenant_id", "id", "kind"]
          },
        ]
      }
      technical_problem: {
        Row: {
          context_of_occurrence: string | null
          id: string
          kind: string
          problem_class: string | null
          symptoms: string[] | null
          tenant_id: string
        }
        Insert: {
          context_of_occurrence?: string | null
          id: string
          kind?: string
          problem_class?: string | null
          symptoms?: string[] | null
          tenant_id?: string
        }
        Update: {
          context_of_occurrence?: string | null
          id?: string
          kind?: string
          problem_class?: string | null
          symptoms?: string[] | null
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "technical_problem_id_fkey"
            columns: ["id"]
            isOneToOne: true
            referencedRelation: "record"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "technical_problem_tenant_id_id_fkey"
            columns: ["tenant_id", "id"]
            isOneToOne: false
            referencedRelation: "record"
            referencedColumns: ["tenant_id", "id"]
          },
          {
            foreignKeyName: "technical_problem_tenant_id_id_kind_fkey"
            columns: ["tenant_id", "id", "kind"]
            isOneToOne: false
            referencedRelation: "record"
            referencedColumns: ["tenant_id", "id", "kind"]
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
          selection_id: string | null
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
          selection_id?: string | null
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
          selection_id?: string | null
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
  provenance: {
    Tables: {
      binding: {
        Row: {
          created_at: string
          external_id: string
          id: string
          object_id: string
          system: string
          tenant_id: string
          updated_at: string
          url: string | null
        }
        Insert: {
          created_at?: string
          external_id: string
          id?: string
          object_id: string
          system: string
          tenant_id?: string
          updated_at?: string
          url?: string | null
        }
        Update: {
          created_at?: string
          external_id?: string
          id?: string
          object_id?: string
          system?: string
          tenant_id?: string
          updated_at?: string
          url?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "binding_object_id_fkey"
            columns: ["object_id"]
            isOneToOne: false
            referencedRelation: "object"
            referencedColumns: ["id"]
          },
        ]
      }
      edge: {
        Row: {
          created_at: string
          from_object_id: string
          from_revision_id: string | null
          id: string
          kind: string
          tenant_id: string
          to_object_id: string
          to_revision_id: string | null
        }
        Insert: {
          created_at?: string
          from_object_id: string
          from_revision_id?: string | null
          id?: string
          kind: string
          tenant_id?: string
          to_object_id: string
          to_revision_id?: string | null
        }
        Update: {
          created_at?: string
          from_object_id?: string
          from_revision_id?: string | null
          id?: string
          kind?: string
          tenant_id?: string
          to_object_id?: string
          to_revision_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "edge_from_object_id_fkey"
            columns: ["from_object_id"]
            isOneToOne: false
            referencedRelation: "object"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "edge_from_revision_id_fkey"
            columns: ["from_revision_id"]
            isOneToOne: false
            referencedRelation: "revision"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "edge_to_object_id_fkey"
            columns: ["to_object_id"]
            isOneToOne: false
            referencedRelation: "object"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "edge_to_revision_id_fkey"
            columns: ["to_revision_id"]
            isOneToOne: false
            referencedRelation: "revision"
            referencedColumns: ["id"]
          },
        ]
      }
      object: {
        Row: {
          created_at: string
          id: string
          key: string
          kind: string
          local_uri: string | null
          tenant_id: string
          title: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          id?: string
          key: string
          kind: string
          local_uri?: string | null
          tenant_id?: string
          title: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          id?: string
          key?: string
          kind?: string
          local_uri?: string | null
          tenant_id?: string
          title?: string
          updated_at?: string
        }
        Relationships: []
      }
      revision: {
        Row: {
          id: string
          media_type: string | null
          object_id: string
          object_path: string
          revision_no: number
          sealed_at: string
          sha256: string
          size_bytes: number | null
          storage_bucket: string
          summary: string | null
          tenant_id: string
        }
        Insert: {
          id?: string
          media_type?: string | null
          object_id: string
          object_path: string
          revision_no: number
          sealed_at?: string
          sha256: string
          size_bytes?: number | null
          storage_bucket?: string
          summary?: string | null
          tenant_id?: string
        }
        Update: {
          id?: string
          media_type?: string | null
          object_id?: string
          object_path?: string
          revision_no?: number
          sealed_at?: string
          sha256?: string
          size_bytes?: number | null
          storage_bucket?: string
          summary?: string | null
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "revision_object_id_fkey"
            columns: ["object_id"]
            isOneToOne: false
            referencedRelation: "object"
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
  public: {
    Tables: {
      factory_artifact: {
        Row: {
          artifact_kind: string
          byte_size: number | null
          contains_sensitive_data: boolean
          content_digest: string
          created_at: string
          factory_artifact_id: string
          factory_episode_id: string
          media_type: string | null
          metadata: Json
          retention_class: string
          storage_uri: string
        }
        Insert: {
          artifact_kind: string
          byte_size?: number | null
          contains_sensitive_data?: boolean
          content_digest: string
          created_at?: string
          factory_artifact_id?: string
          factory_episode_id: string
          media_type?: string | null
          metadata?: Json
          retention_class?: string
          storage_uri: string
        }
        Update: {
          artifact_kind?: string
          byte_size?: number | null
          contains_sensitive_data?: boolean
          content_digest?: string
          created_at?: string
          factory_artifact_id?: string
          factory_episode_id?: string
          media_type?: string | null
          metadata?: Json
          retention_class?: string
          storage_uri?: string
        }
        Relationships: [
          {
            foreignKeyName: "factory_artifact_factory_episode_id_fkey"
            columns: ["factory_episode_id"]
            isOneToOne: false
            referencedRelation: "factory_episode"
            referencedColumns: ["factory_episode_id"]
          },
        ]
      }
      factory_assertion_result: {
        Row: {
          assertion_key: string
          assertion_kind: string
          created_at: string
          details: Json
          evaluator_version: string
          evidence_artifact_ids: string[]
          factory_assertion_result_id: string
          factory_episode_id: string
          hard_gate: boolean
          passed: boolean
          score: number | null
        }
        Insert: {
          assertion_key: string
          assertion_kind: string
          created_at?: string
          details?: Json
          evaluator_version: string
          evidence_artifact_ids?: string[]
          factory_assertion_result_id?: string
          factory_episode_id: string
          hard_gate?: boolean
          passed: boolean
          score?: number | null
        }
        Update: {
          assertion_key?: string
          assertion_kind?: string
          created_at?: string
          details?: Json
          evaluator_version?: string
          evidence_artifact_ids?: string[]
          factory_assertion_result_id?: string
          factory_episode_id?: string
          hard_gate?: boolean
          passed?: boolean
          score?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "factory_assertion_result_factory_episode_id_fkey"
            columns: ["factory_episode_id"]
            isOneToOne: false
            referencedRelation: "factory_episode"
            referencedColumns: ["factory_episode_id"]
          },
        ]
      }
      factory_canary_result: {
        Row: {
          created_at: string
          factory_canary_result_id: string
          finished_at: string | null
          metrics: Json
          promotion_decision_id: string
          rollback_reason: string | null
          started_at: string
          status: string
          traffic_fraction: number
        }
        Insert: {
          created_at?: string
          factory_canary_result_id?: string
          finished_at?: string | null
          metrics?: Json
          promotion_decision_id: string
          rollback_reason?: string | null
          started_at: string
          status?: string
          traffic_fraction: number
        }
        Update: {
          created_at?: string
          factory_canary_result_id?: string
          finished_at?: string | null
          metrics?: Json
          promotion_decision_id?: string
          rollback_reason?: string | null
          started_at?: string
          status?: string
          traffic_fraction?: number
        }
        Relationships: [
          {
            foreignKeyName: "factory_canary_result_promotion_decision_id_fkey"
            columns: ["promotion_decision_id"]
            isOneToOne: false
            referencedRelation: "factory_promotion_decision"
            referencedColumns: ["factory_promotion_decision_id"]
          },
        ]
      }
      factory_candidate: {
        Row: {
          candidate_kind: string
          component_versions: Json
          content_digest: string
          created_at: string
          factory_candidate_id: string
          mutation_surface: Json
          parent_candidate_id: string | null
          proposer: string
          rationale: string
          source_revision: string
          status: string
        }
        Insert: {
          candidate_kind: string
          component_versions: Json
          content_digest: string
          created_at?: string
          factory_candidate_id?: string
          mutation_surface: Json
          parent_candidate_id?: string | null
          proposer: string
          rationale: string
          source_revision: string
          status?: string
        }
        Update: {
          candidate_kind?: string
          component_versions?: Json
          content_digest?: string
          created_at?: string
          factory_candidate_id?: string
          mutation_surface?: Json
          parent_candidate_id?: string | null
          proposer?: string
          rationale?: string
          source_revision?: string
          status?: string
        }
        Relationships: [
          {
            foreignKeyName: "factory_candidate_parent_candidate_id_fkey"
            columns: ["parent_candidate_id"]
            isOneToOne: false
            referencedRelation: "factory_candidate"
            referencedColumns: ["factory_candidate_id"]
          },
        ]
      }
      factory_component_version: {
        Row: {
          component_kind: string
          component_version_id: string
          content_digest: string
          created_at: string
          metadata: Json
          slug: string
          source_revision: string
          storage_uri: string | null
          version: string
        }
        Insert: {
          component_kind: string
          component_version_id?: string
          content_digest: string
          created_at?: string
          metadata?: Json
          slug: string
          source_revision: string
          storage_uri?: string | null
          version: string
        }
        Update: {
          component_kind?: string
          component_version_id?: string
          content_digest?: string
          created_at?: string
          metadata?: Json
          slug?: string
          source_revision?: string
          storage_uri?: string | null
          version?: string
        }
        Relationships: []
      }
      factory_environment_version: {
        Row: {
          created_at: string
          environment_version_id: string
          image_digest: string
          protocol_version: string
          reward_contract_version: string
          slug: string
          spec: Json
          status: string
          task_kind: string
          verifier_bundle_digest: string
          version: string
        }
        Insert: {
          created_at?: string
          environment_version_id?: string
          image_digest: string
          protocol_version?: string
          reward_contract_version: string
          slug: string
          spec: Json
          status?: string
          task_kind: string
          verifier_bundle_digest: string
          version: string
        }
        Update: {
          created_at?: string
          environment_version_id?: string
          image_digest?: string
          protocol_version?: string
          reward_contract_version?: string
          slug?: string
          spec?: Json
          status?: string
          task_kind?: string
          verifier_bundle_digest?: string
          version?: string
        }
        Relationships: []
      }
      factory_episode: {
        Row: {
          attempt_id: string | null
          cost_usd: number
          created_at: string
          duration_ms: number | null
          environment_version_id: string
          eve_session_id: string | null
          factory_candidate_id: string
          factory_episode_id: string
          factory_task_id: string
          finished_at: string | null
          idempotency_key: string
          metadata: Json
          model_tokens: number
          sandbox_provider: string | null
          sandbox_session_id: string | null
          seed: number
          source_revision: string
          started_at: string | null
          status: string
          terminal_state: string | null
          workflow_run_id: string | null
        }
        Insert: {
          attempt_id?: string | null
          cost_usd?: number
          created_at?: string
          duration_ms?: number | null
          environment_version_id: string
          eve_session_id?: string | null
          factory_candidate_id: string
          factory_episode_id?: string
          factory_task_id: string
          finished_at?: string | null
          idempotency_key: string
          metadata?: Json
          model_tokens?: number
          sandbox_provider?: string | null
          sandbox_session_id?: string | null
          seed: number
          source_revision: string
          started_at?: string | null
          status?: string
          terminal_state?: string | null
          workflow_run_id?: string | null
        }
        Update: {
          attempt_id?: string | null
          cost_usd?: number
          created_at?: string
          duration_ms?: number | null
          environment_version_id?: string
          eve_session_id?: string | null
          factory_candidate_id?: string
          factory_episode_id?: string
          factory_task_id?: string
          finished_at?: string | null
          idempotency_key?: string
          metadata?: Json
          model_tokens?: number
          sandbox_provider?: string | null
          sandbox_session_id?: string | null
          seed?: number
          source_revision?: string
          started_at?: string | null
          status?: string
          terminal_state?: string | null
          workflow_run_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "factory_episode_environment_version_id_fkey"
            columns: ["environment_version_id"]
            isOneToOne: false
            referencedRelation: "factory_environment_version"
            referencedColumns: ["environment_version_id"]
          },
          {
            foreignKeyName: "factory_episode_factory_candidate_id_fkey"
            columns: ["factory_candidate_id"]
            isOneToOne: false
            referencedRelation: "factory_candidate"
            referencedColumns: ["factory_candidate_id"]
          },
          {
            foreignKeyName: "factory_episode_factory_task_id_fkey"
            columns: ["factory_task_id"]
            isOneToOne: false
            referencedRelation: "factory_task"
            referencedColumns: ["factory_task_id"]
          },
        ]
      }
      factory_evolution_proposal: {
        Row: {
          budget: Json
          created_at: string
          evaluation_plan: Json
          factory_evolution_proposal_id: string
          failure_cluster_id: string | null
          hypothesis: string
          hypothesized_component_kind: string
          mutation_surface: Json
          predicted_impact: Json
          proposed_candidate_id: string | null
          risks: Json
          rollback_component_version_id: string | null
          status: string
          stop_condition: Json
        }
        Insert: {
          budget: Json
          created_at?: string
          evaluation_plan: Json
          factory_evolution_proposal_id?: string
          failure_cluster_id?: string | null
          hypothesis: string
          hypothesized_component_kind: string
          mutation_surface: Json
          predicted_impact: Json
          proposed_candidate_id?: string | null
          risks: Json
          rollback_component_version_id?: string | null
          status?: string
          stop_condition: Json
        }
        Update: {
          budget?: Json
          created_at?: string
          evaluation_plan?: Json
          factory_evolution_proposal_id?: string
          failure_cluster_id?: string | null
          hypothesis?: string
          hypothesized_component_kind?: string
          mutation_surface?: Json
          predicted_impact?: Json
          proposed_candidate_id?: string | null
          risks?: Json
          rollback_component_version_id?: string | null
          status?: string
          stop_condition?: Json
        }
        Relationships: [
          {
            foreignKeyName: "factory_evolution_proposal_failure_cluster_id_fkey"
            columns: ["failure_cluster_id"]
            isOneToOne: false
            referencedRelation: "factory_failure_cluster"
            referencedColumns: ["factory_failure_cluster_id"]
          },
          {
            foreignKeyName: "factory_evolution_proposal_proposed_candidate_id_fkey"
            columns: ["proposed_candidate_id"]
            isOneToOne: false
            referencedRelation: "factory_candidate"
            referencedColumns: ["factory_candidate_id"]
          },
          {
            foreignKeyName: "factory_evolution_proposal_rollback_component_version_id_fkey"
            columns: ["rollback_component_version_id"]
            isOneToOne: false
            referencedRelation: "factory_component_version"
            referencedColumns: ["component_version_id"]
          },
        ]
      }
      factory_experiment: {
        Row: {
          created_at: string
          evolution_proposal_id: string
          experiment_version: string
          factory_experiment_id: string
          finished_at: string | null
          policy: Json
          split_manifest_digest: string
          started_at: string | null
          status: string
        }
        Insert: {
          created_at?: string
          evolution_proposal_id: string
          experiment_version: string
          factory_experiment_id?: string
          finished_at?: string | null
          policy: Json
          split_manifest_digest: string
          started_at?: string | null
          status?: string
        }
        Update: {
          created_at?: string
          evolution_proposal_id?: string
          experiment_version?: string
          factory_experiment_id?: string
          finished_at?: string | null
          policy?: Json
          split_manifest_digest?: string
          started_at?: string | null
          status?: string
        }
        Relationships: [
          {
            foreignKeyName: "factory_experiment_evolution_proposal_id_fkey"
            columns: ["evolution_proposal_id"]
            isOneToOne: false
            referencedRelation: "factory_evolution_proposal"
            referencedColumns: ["factory_evolution_proposal_id"]
          },
        ]
      }
      factory_experiment_arm: {
        Row: {
          aggregate_metrics: Json
          arm_name: string
          assignment_probability: number | null
          created_at: string
          episode_ids: string[]
          factory_candidate_id: string
          factory_experiment_arm_id: string
          factory_experiment_id: string
        }
        Insert: {
          aggregate_metrics?: Json
          arm_name: string
          assignment_probability?: number | null
          created_at?: string
          episode_ids?: string[]
          factory_candidate_id: string
          factory_experiment_arm_id?: string
          factory_experiment_id: string
        }
        Update: {
          aggregate_metrics?: Json
          arm_name?: string
          assignment_probability?: number | null
          created_at?: string
          episode_ids?: string[]
          factory_candidate_id?: string
          factory_experiment_arm_id?: string
          factory_experiment_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "factory_experiment_arm_factory_candidate_id_fkey"
            columns: ["factory_candidate_id"]
            isOneToOne: false
            referencedRelation: "factory_candidate"
            referencedColumns: ["factory_candidate_id"]
          },
          {
            foreignKeyName: "factory_experiment_arm_factory_experiment_id_fkey"
            columns: ["factory_experiment_id"]
            isOneToOne: false
            referencedRelation: "factory_experiment"
            referencedColumns: ["factory_experiment_id"]
          },
        ]
      }
      factory_failure_cluster: {
        Row: {
          affected_episode_ids: string[]
          created_at: string
          evidence: Json
          factory_failure_cluster_id: string
          severity: string
          signature: string
          status: string
          taxonomy_code: string
          title: string
          updated_at: string
        }
        Insert: {
          affected_episode_ids?: string[]
          created_at?: string
          evidence: Json
          factory_failure_cluster_id?: string
          severity: string
          signature: string
          status?: string
          taxonomy_code: string
          title: string
          updated_at?: string
        }
        Update: {
          affected_episode_ids?: string[]
          created_at?: string
          evidence?: Json
          factory_failure_cluster_id?: string
          severity?: string
          signature?: string
          status?: string
          taxonomy_code?: string
          title?: string
          updated_at?: string
        }
        Relationships: []
      }
      factory_promotion_decision: {
        Row: {
          baseline_candidate_id: string
          candidate_id: string
          created_at: string
          decided_by: string
          decision: string
          evidence: Json
          factory_experiment_id: string
          factory_promotion_decision_id: string
          promotion_policy_version: string
          reasons: string[]
          rollback_component_version_id: string | null
        }
        Insert: {
          baseline_candidate_id: string
          candidate_id: string
          created_at?: string
          decided_by: string
          decision: string
          evidence: Json
          factory_experiment_id: string
          factory_promotion_decision_id?: string
          promotion_policy_version: string
          reasons?: string[]
          rollback_component_version_id?: string | null
        }
        Update: {
          baseline_candidate_id?: string
          candidate_id?: string
          created_at?: string
          decided_by?: string
          decision?: string
          evidence?: Json
          factory_experiment_id?: string
          factory_promotion_decision_id?: string
          promotion_policy_version?: string
          reasons?: string[]
          rollback_component_version_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "factory_promotion_decision_baseline_candidate_id_fkey"
            columns: ["baseline_candidate_id"]
            isOneToOne: false
            referencedRelation: "factory_candidate"
            referencedColumns: ["factory_candidate_id"]
          },
          {
            foreignKeyName: "factory_promotion_decision_candidate_id_fkey"
            columns: ["candidate_id"]
            isOneToOne: false
            referencedRelation: "factory_candidate"
            referencedColumns: ["factory_candidate_id"]
          },
          {
            foreignKeyName: "factory_promotion_decision_factory_experiment_id_fkey"
            columns: ["factory_experiment_id"]
            isOneToOne: false
            referencedRelation: "factory_experiment"
            referencedColumns: ["factory_experiment_id"]
          },
          {
            foreignKeyName: "factory_promotion_decision_rollback_component_version_id_fkey"
            columns: ["rollback_component_version_id"]
            isOneToOne: false
            referencedRelation: "factory_component_version"
            referencedColumns: ["component_version_id"]
          },
        ]
      }
      factory_runtime_event: {
        Row: {
          agent_name: string
          agent_node_id: string | null
          call_id: string | null
          channel_kind: string | null
          emitted_at: string
          eve_event_id: string
          eve_session_id: string
          event_data: Json | null
          event_meta: Json
          event_ordinal: number
          event_type: string
          factory_episode_id: string
          ingested_at: string
          issue_number: number | null
          payload_byte_size: number
          payload_sha256: string
          payload_truncated: boolean
          redaction_version: string
          repository: string | null
          retention_until: string
          sensitivity_class: string
          subagent_name: string | null
        }
        Insert: {
          agent_name: string
          agent_node_id?: string | null
          call_id?: string | null
          channel_kind?: string | null
          emitted_at: string
          eve_event_id: string
          eve_session_id: string
          event_data?: Json | null
          event_meta: Json
          event_ordinal: number
          event_type: string
          factory_episode_id: string
          ingested_at?: string
          issue_number?: number | null
          payload_byte_size: number
          payload_sha256: string
          payload_truncated?: boolean
          redaction_version?: string
          repository?: string | null
          retention_until?: string
          sensitivity_class?: string
          subagent_name?: string | null
        }
        Update: {
          agent_name?: string
          agent_node_id?: string | null
          call_id?: string | null
          channel_kind?: string | null
          emitted_at?: string
          eve_event_id?: string
          eve_session_id?: string
          event_data?: Json | null
          event_meta?: Json
          event_ordinal?: number
          event_type?: string
          factory_episode_id?: string
          ingested_at?: string
          issue_number?: number | null
          payload_byte_size?: number
          payload_sha256?: string
          payload_truncated?: boolean
          redaction_version?: string
          repository?: string | null
          retention_until?: string
          sensitivity_class?: string
          subagent_name?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "factory_runtime_event_factory_episode_id_fkey"
            columns: ["factory_episode_id"]
            isOneToOne: false
            referencedRelation: "factory_episode"
            referencedColumns: ["factory_episode_id"]
          },
        ]
      }
      factory_score_vector: {
        Row: {
          created_at: string
          eligible_for_promotion: boolean
          factory_episode_id: string
          factory_score_vector_id: string
          ineligibility_reasons: string[]
          reward_contract_version: string
          vector: Json
          weighted_score: number | null
        }
        Insert: {
          created_at?: string
          eligible_for_promotion?: boolean
          factory_episode_id: string
          factory_score_vector_id?: string
          ineligibility_reasons?: string[]
          reward_contract_version: string
          vector: Json
          weighted_score?: number | null
        }
        Update: {
          created_at?: string
          eligible_for_promotion?: boolean
          factory_episode_id?: string
          factory_score_vector_id?: string
          ineligibility_reasons?: string[]
          reward_contract_version?: string
          vector?: Json
          weighted_score?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "factory_score_vector_factory_episode_id_fkey"
            columns: ["factory_episode_id"]
            isOneToOne: false
            referencedRelation: "factory_episode"
            referencedColumns: ["factory_episode_id"]
          },
        ]
      }
      factory_task: {
        Row: {
          challenge_id: string | null
          created_at: string
          data_split: string
          factory_task_id: string
          parent_task_id: string | null
          risk_tier: string
          slug: string
          spec: Json
          spec_digest: string
          status: string
          task_kind: string
          version: string
        }
        Insert: {
          challenge_id?: string | null
          created_at?: string
          data_split: string
          factory_task_id?: string
          parent_task_id?: string | null
          risk_tier?: string
          slug: string
          spec: Json
          spec_digest: string
          status?: string
          task_kind: string
          version: string
        }
        Update: {
          challenge_id?: string | null
          created_at?: string
          data_split?: string
          factory_task_id?: string
          parent_task_id?: string | null
          risk_tier?: string
          slug?: string
          spec?: Json
          spec_digest?: string
          status?: string
          task_kind?: string
          version?: string
        }
        Relationships: [
          {
            foreignKeyName: "factory_task_parent_task_id_fkey"
            columns: ["parent_task_id"]
            isOneToOne: false
            referencedRelation: "factory_task"
            referencedColumns: ["factory_task_id"]
          },
        ]
      }
      factory_trace_span_ref: {
        Row: {
          agent_role: string | null
          artifact_id: string | null
          attributes: Json
          factory_episode_id: string
          factory_trace_span_ref_id: string
          finished_at: string | null
          operation_name: string
          parent_span_id: string | null
          span_id: string
          started_at: string | null
          trace_id: string
        }
        Insert: {
          agent_role?: string | null
          artifact_id?: string | null
          attributes?: Json
          factory_episode_id: string
          factory_trace_span_ref_id?: string
          finished_at?: string | null
          operation_name: string
          parent_span_id?: string | null
          span_id: string
          started_at?: string | null
          trace_id: string
        }
        Update: {
          agent_role?: string | null
          artifact_id?: string | null
          attributes?: Json
          factory_episode_id?: string
          factory_trace_span_ref_id?: string
          finished_at?: string | null
          operation_name?: string
          parent_span_id?: string | null
          span_id?: string
          started_at?: string | null
          trace_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "factory_trace_span_ref_artifact_id_fkey"
            columns: ["artifact_id"]
            isOneToOne: false
            referencedRelation: "factory_artifact"
            referencedColumns: ["factory_artifact_id"]
          },
          {
            foreignKeyName: "factory_trace_span_ref_factory_episode_id_fkey"
            columns: ["factory_episode_id"]
            isOneToOne: false
            referencedRelation: "factory_episode"
            referencedColumns: ["factory_episode_id"]
          },
        ]
      }
      research_application_domain: {
        Row: {
          active: boolean
          description: string
          domain_code: string
          label: string
          parent_domain_code: string | null
          sort_order: number
        }
        Insert: {
          active?: boolean
          description: string
          domain_code: string
          label: string
          parent_domain_code?: string | null
          sort_order?: number
        }
        Update: {
          active?: boolean
          description?: string
          domain_code?: string
          label?: string
          parent_domain_code?: string | null
          sort_order?: number
        }
        Relationships: [
          {
            foreignKeyName: "research_application_domain_parent_domain_code_fkey"
            columns: ["parent_domain_code"]
            isOneToOne: false
            referencedRelation: "research_application_domain"
            referencedColumns: ["domain_code"]
          },
        ]
      }
      research_category_definition: {
        Row: {
          category_code: Database["public"]["Enums"]["research_engineering_category_code"]
          description: string
          example_topics: string[]
          exclusion_criteria: string[]
          inclusion_criteria: string[]
          label: string
          sort_order: number
          taxonomy_version_id: string
        }
        Insert: {
          category_code: Database["public"]["Enums"]["research_engineering_category_code"]
          description: string
          example_topics?: string[]
          exclusion_criteria?: string[]
          inclusion_criteria?: string[]
          label: string
          sort_order: number
          taxonomy_version_id: string
        }
        Update: {
          category_code?: Database["public"]["Enums"]["research_engineering_category_code"]
          description?: string
          example_topics?: string[]
          exclusion_criteria?: string[]
          inclusion_criteria?: string[]
          label?: string
          sort_order?: number
          taxonomy_version_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "research_category_definition_taxonomy_version_id_fkey"
            columns: ["taxonomy_version_id"]
            isOneToOne: false
            referencedRelation: "research_taxonomy_version"
            referencedColumns: ["taxonomy_version_id"]
          },
        ]
      }
      research_entity_candidate: {
        Row: {
          analysis_id: string
          candidate_id: string
          canonical_url: string | null
          confidence: number
          entity_kind: Database["public"]["Enums"]["research_entity_kind"]
          evidence_ids: string[]
          name: string
          normalized_name: string
          organization_name: string | null
          relationship_to_video: string
          verification_status: Database["public"]["Enums"]["research_verification_status"]
        }
        Insert: {
          analysis_id: string
          candidate_id?: string
          canonical_url?: string | null
          confidence: number
          entity_kind: Database["public"]["Enums"]["research_entity_kind"]
          evidence_ids?: string[]
          name: string
          normalized_name: string
          organization_name?: string | null
          relationship_to_video: string
          verification_status: Database["public"]["Enums"]["research_verification_status"]
        }
        Update: {
          analysis_id?: string
          candidate_id?: string
          canonical_url?: string | null
          confidence?: number
          entity_kind?: Database["public"]["Enums"]["research_entity_kind"]
          evidence_ids?: string[]
          name?: string
          normalized_name?: string
          organization_name?: string | null
          relationship_to_video?: string
          verification_status?: Database["public"]["Enums"]["research_verification_status"]
        }
        Relationships: [
          {
            foreignKeyName: "research_entity_candidate_analysis_id_fkey"
            columns: ["analysis_id"]
            isOneToOne: false
            referencedRelation: "research_video_analysis"
            referencedColumns: ["analysis_id"]
          },
        ]
      }
      research_evidence_anchor: {
        Row: {
          analysis_id: string
          end_character: number | null
          end_seconds: number | null
          evidence_id: string
          short_excerpt: string
          source_kind: Database["public"]["Enums"]["research_evidence_source_kind"]
          source_url: string | null
          start_character: number | null
          start_seconds: number | null
          supports: string
          transcript_segment: string | null
        }
        Insert: {
          analysis_id: string
          end_character?: number | null
          end_seconds?: number | null
          evidence_id?: string
          short_excerpt: string
          source_kind: Database["public"]["Enums"]["research_evidence_source_kind"]
          source_url?: string | null
          start_character?: number | null
          start_seconds?: number | null
          supports: string
          transcript_segment?: string | null
        }
        Update: {
          analysis_id?: string
          end_character?: number | null
          end_seconds?: number | null
          evidence_id?: string
          short_excerpt?: string
          source_kind?: Database["public"]["Enums"]["research_evidence_source_kind"]
          source_url?: string | null
          start_character?: number | null
          start_seconds?: number | null
          supports?: string
          transcript_segment?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "research_evidence_anchor_analysis_id_fkey"
            columns: ["analysis_id"]
            isOneToOne: false
            referencedRelation: "research_video_analysis"
            referencedColumns: ["analysis_id"]
          },
        ]
      }
      research_ingestion_intent: {
        Row: {
          applied_at: string | null
          content_sha256: string
          created_at: string
          error_detail: string | null
          idempotency_key: string
          intent_id: string
          rejected_at: string | null
          run_id: string
          schema_version: string
          status: Database["public"]["Enums"]["research_intent_status"]
          storage_bucket: string
          storage_path: string
          validated_at: string | null
          video_id: string
        }
        Insert: {
          applied_at?: string | null
          content_sha256: string
          created_at?: string
          error_detail?: string | null
          idempotency_key: string
          intent_id?: string
          rejected_at?: string | null
          run_id: string
          schema_version: string
          status?: Database["public"]["Enums"]["research_intent_status"]
          storage_bucket: string
          storage_path: string
          validated_at?: string | null
          video_id: string
        }
        Update: {
          applied_at?: string | null
          content_sha256?: string
          created_at?: string
          error_detail?: string | null
          idempotency_key?: string
          intent_id?: string
          rejected_at?: string | null
          run_id?: string
          schema_version?: string
          status?: Database["public"]["Enums"]["research_intent_status"]
          storage_bucket?: string
          storage_path?: string
          validated_at?: string | null
          video_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "research_ingestion_intent_run_id_fkey"
            columns: ["run_id"]
            isOneToOne: true
            referencedRelation: "research_pre_research_run"
            referencedColumns: ["run_id"]
          },
          {
            foreignKeyName: "research_ingestion_intent_video_id_fkey"
            columns: ["video_id"]
            isOneToOne: false
            referencedRelation: "research_starter_videos"
            referencedColumns: ["video_id"]
          },
        ]
      }
      research_ingestion_intent_event: {
        Row: {
          affected_key: string | null
          affected_table: string | null
          created_at: string
          error_detail: string | null
          event_id: string
          intent_id: string
          operation_index: number
          operation_kind: string
          status: Database["public"]["Enums"]["research_intent_event_status"]
        }
        Insert: {
          affected_key?: string | null
          affected_table?: string | null
          created_at?: string
          error_detail?: string | null
          event_id?: string
          intent_id: string
          operation_index: number
          operation_kind: string
          status: Database["public"]["Enums"]["research_intent_event_status"]
        }
        Update: {
          affected_key?: string | null
          affected_table?: string | null
          created_at?: string
          error_detail?: string | null
          event_id?: string
          intent_id?: string
          operation_index?: number
          operation_kind?: string
          status?: Database["public"]["Enums"]["research_intent_event_status"]
        }
        Relationships: [
          {
            foreignKeyName: "research_ingestion_intent_event_intent_id_fkey"
            columns: ["intent_id"]
            isOneToOne: false
            referencedRelation: "research_ingestion_intent"
            referencedColumns: ["intent_id"]
          },
        ]
      }
      research_organization_candidate: {
        Row: {
          analysis_id: string
          authoritative_summary: string
          canonical_name: string
          confidence: number
          current_status: string
          evidence_ids: string[]
          featured_rank: number
          generated_at: string
          is_primary_featured: boolean
          normalized_name: string
          official_url: string
          organization_candidate_id: string
          organization_scope: Database["public"]["Enums"]["research_organization_scope"]
          ownership_changed_since_video: boolean
          parent_canonical_url: string | null
          parent_name: string | null
          primary_domain_code: Database["public"]["Enums"]["research_organization_domain_code"]
          relationship_roles: Database["public"]["Enums"]["research_video_organization_role"][]
          relationship_to_implementation: string
          secondary_domain_codes: Database["public"]["Enums"]["research_organization_domain_code"][]
          status_as_of: string
          video_id: string
          video_time_name: string | null
          video_time_parent_name: string | null
        }
        Insert: {
          analysis_id: string
          authoritative_summary: string
          canonical_name: string
          confidence: number
          current_status: string
          evidence_ids?: string[]
          featured_rank: number
          generated_at?: string
          is_primary_featured?: boolean
          normalized_name: string
          official_url: string
          organization_candidate_id?: string
          organization_scope: Database["public"]["Enums"]["research_organization_scope"]
          ownership_changed_since_video?: boolean
          parent_canonical_url?: string | null
          parent_name?: string | null
          primary_domain_code: Database["public"]["Enums"]["research_organization_domain_code"]
          relationship_roles: Database["public"]["Enums"]["research_video_organization_role"][]
          relationship_to_implementation: string
          secondary_domain_codes?: Database["public"]["Enums"]["research_organization_domain_code"][]
          status_as_of: string
          video_id: string
          video_time_name?: string | null
          video_time_parent_name?: string | null
        }
        Update: {
          analysis_id?: string
          authoritative_summary?: string
          canonical_name?: string
          confidence?: number
          current_status?: string
          evidence_ids?: string[]
          featured_rank?: number
          generated_at?: string
          is_primary_featured?: boolean
          normalized_name?: string
          official_url?: string
          organization_candidate_id?: string
          organization_scope?: Database["public"]["Enums"]["research_organization_scope"]
          ownership_changed_since_video?: boolean
          parent_canonical_url?: string | null
          parent_name?: string | null
          primary_domain_code?: Database["public"]["Enums"]["research_organization_domain_code"]
          relationship_roles?: Database["public"]["Enums"]["research_video_organization_role"][]
          relationship_to_implementation?: string
          secondary_domain_codes?: Database["public"]["Enums"]["research_organization_domain_code"][]
          status_as_of?: string
          video_id?: string
          video_time_name?: string | null
          video_time_parent_name?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "research_organization_candidate_analysis_id_fkey"
            columns: ["analysis_id"]
            isOneToOne: false
            referencedRelation: "research_video_analysis"
            referencedColumns: ["analysis_id"]
          },
          {
            foreignKeyName: "research_organization_candidate_video_id_fkey"
            columns: ["video_id"]
            isOneToOne: false
            referencedRelation: "research_starter_videos"
            referencedColumns: ["video_id"]
          },
        ]
      }
      research_organization_domain_definition: {
        Row: {
          active: boolean
          definition_version: string
          description: string
          domain_code: Database["public"]["Enums"]["research_organization_domain_code"]
          example_organizations: string[]
          exclusion_criteria: string[]
          inclusion_criteria: string[]
          label: string
          sort_order: number
        }
        Insert: {
          active?: boolean
          definition_version?: string
          description: string
          domain_code: Database["public"]["Enums"]["research_organization_domain_code"]
          example_organizations?: string[]
          exclusion_criteria?: string[]
          inclusion_criteria?: string[]
          label: string
          sort_order: number
        }
        Update: {
          active?: boolean
          definition_version?: string
          description?: string
          domain_code?: Database["public"]["Enums"]["research_organization_domain_code"]
          example_organizations?: string[]
          exclusion_criteria?: string[]
          inclusion_criteria?: string[]
          label?: string
          sort_order?: number
        }
        Relationships: []
      }
      research_organization_source: {
        Row: {
          authority_tier: string
          evidence_id: string | null
          is_required_core_source: boolean
          normalized_url: string
          organization_candidate_id: string
          organization_source_id: string
          publicly_retrievable: boolean
          publisher: string
          retrieved_at: string
          source_published_at: string | null
          source_rank: number
          source_role: string
          supports: Json
          title: string
          url: string
          verification_status: Database["public"]["Enums"]["research_verification_status"]
        }
        Insert: {
          authority_tier: string
          evidence_id?: string | null
          is_required_core_source?: boolean
          normalized_url: string
          organization_candidate_id: string
          organization_source_id?: string
          publicly_retrievable: boolean
          publisher: string
          retrieved_at: string
          source_published_at?: string | null
          source_rank: number
          source_role: string
          supports?: Json
          title: string
          url: string
          verification_status: Database["public"]["Enums"]["research_verification_status"]
        }
        Update: {
          authority_tier?: string
          evidence_id?: string | null
          is_required_core_source?: boolean
          normalized_url?: string
          organization_candidate_id?: string
          organization_source_id?: string
          publicly_retrievable?: boolean
          publisher?: string
          retrieved_at?: string
          source_published_at?: string | null
          source_rank?: number
          source_role?: string
          supports?: Json
          title?: string
          url?: string
          verification_status?: Database["public"]["Enums"]["research_verification_status"]
        }
        Relationships: [
          {
            foreignKeyName: "research_organization_source_evidence_id_fkey"
            columns: ["evidence_id"]
            isOneToOne: false
            referencedRelation: "research_evidence_anchor"
            referencedColumns: ["evidence_id"]
          },
          {
            foreignKeyName: "research_organization_source_organization_candidate_id_fkey"
            columns: ["organization_candidate_id"]
            isOneToOne: false
            referencedRelation: "research_organization_candidate"
            referencedColumns: ["organization_candidate_id"]
          },
        ]
      }
      research_pre_research_artifact: {
        Row: {
          artifact_id: string
          artifact_kind: string
          byte_count: number
          content_sha256: string
          created_at: string
          intent_id: string | null
          run_id: string
          schema_version: string
          storage_bucket: string
          storage_path: string
        }
        Insert: {
          artifact_id?: string
          artifact_kind: string
          byte_count: number
          content_sha256: string
          created_at?: string
          intent_id?: string | null
          run_id: string
          schema_version: string
          storage_bucket: string
          storage_path: string
        }
        Update: {
          artifact_id?: string
          artifact_kind?: string
          byte_count?: number
          content_sha256?: string
          created_at?: string
          intent_id?: string | null
          run_id?: string
          schema_version?: string
          storage_bucket?: string
          storage_path?: string
        }
        Relationships: [
          {
            foreignKeyName: "research_pre_research_artifact_intent_id_fkey"
            columns: ["intent_id"]
            isOneToOne: false
            referencedRelation: "research_ingestion_intent"
            referencedColumns: ["intent_id"]
          },
          {
            foreignKeyName: "research_pre_research_artifact_run_id_fkey"
            columns: ["run_id"]
            isOneToOne: false
            referencedRelation: "research_pre_research_run"
            referencedColumns: ["run_id"]
          },
        ]
      }
      research_pre_research_run: {
        Row: {
          attempt: number
          completed_at: string | null
          created_at: string
          error_code: string | null
          error_detail: string | null
          intent_path: string | null
          intent_sha256: string | null
          lease_expires_at: string | null
          lease_token: string | null
          model_id: string
          packet_schema_version: string
          packet_sha256: string | null
          packet_storage_prefix: string | null
          prompt_bundle_version: string
          research_as_of: string
          research_completed_at: string | null
          research_session_id: string | null
          run_id: string
          started_at: string | null
          status: Database["public"]["Enums"]["research_pre_research_run_status"]
          synthesis_session_id: string | null
          synthesis_started_at: string | null
          taxonomy_version_id: string
          transcript_sha256: string
          updated_at: string
          video_id: string
          workflow_session_id: string | null
        }
        Insert: {
          attempt?: number
          completed_at?: string | null
          created_at?: string
          error_code?: string | null
          error_detail?: string | null
          intent_path?: string | null
          intent_sha256?: string | null
          lease_expires_at?: string | null
          lease_token?: string | null
          model_id: string
          packet_schema_version?: string
          packet_sha256?: string | null
          packet_storage_prefix?: string | null
          prompt_bundle_version: string
          research_as_of?: string
          research_completed_at?: string | null
          research_session_id?: string | null
          run_id?: string
          started_at?: string | null
          status?: Database["public"]["Enums"]["research_pre_research_run_status"]
          synthesis_session_id?: string | null
          synthesis_started_at?: string | null
          taxonomy_version_id: string
          transcript_sha256: string
          updated_at?: string
          video_id: string
          workflow_session_id?: string | null
        }
        Update: {
          attempt?: number
          completed_at?: string | null
          created_at?: string
          error_code?: string | null
          error_detail?: string | null
          intent_path?: string | null
          intent_sha256?: string | null
          lease_expires_at?: string | null
          lease_token?: string | null
          model_id?: string
          packet_schema_version?: string
          packet_sha256?: string | null
          packet_storage_prefix?: string | null
          prompt_bundle_version?: string
          research_as_of?: string
          research_completed_at?: string | null
          research_session_id?: string | null
          run_id?: string
          started_at?: string | null
          status?: Database["public"]["Enums"]["research_pre_research_run_status"]
          synthesis_session_id?: string | null
          synthesis_started_at?: string | null
          taxonomy_version_id?: string
          transcript_sha256?: string
          updated_at?: string
          video_id?: string
          workflow_session_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "research_pre_research_run_taxonomy_version_id_fkey"
            columns: ["taxonomy_version_id"]
            isOneToOne: false
            referencedRelation: "research_taxonomy_version"
            referencedColumns: ["taxonomy_version_id"]
          },
          {
            foreignKeyName: "research_pre_research_run_video_id_fkey"
            columns: ["video_id"]
            isOneToOne: false
            referencedRelation: "research_starter_videos"
            referencedColumns: ["video_id"]
          },
        ]
      }
      research_pre_research_session: {
        Row: {
          attempt: number
          completed_at: string | null
          error_code: string | null
          error_detail: string | null
          eve_session_id: string
          phase: string
          pre_research_session_id: string
          result_summary: Json | null
          run_id: string
          started_at: string
          status: string
        }
        Insert: {
          attempt: number
          completed_at?: string | null
          error_code?: string | null
          error_detail?: string | null
          eve_session_id: string
          phase: string
          pre_research_session_id?: string
          result_summary?: Json | null
          run_id: string
          started_at?: string
          status: string
        }
        Update: {
          attempt?: number
          completed_at?: string | null
          error_code?: string | null
          error_detail?: string | null
          eve_session_id?: string
          phase?: string
          pre_research_session_id?: string
          result_summary?: Json | null
          run_id?: string
          started_at?: string
          status?: string
        }
        Relationships: [
          {
            foreignKeyName: "research_pre_research_session_run_id_fkey"
            columns: ["run_id"]
            isOneToOne: false
            referencedRelation: "research_pre_research_run"
            referencedColumns: ["run_id"]
          },
        ]
      }
      research_pre_research_stage_execution: {
        Row: {
          attempt_count: number
          completed_artifact_sha256s: Json
          completed_at: string | null
          input_manifest_bucket: string | null
          input_manifest_path: string | null
          input_sha256: string | null
          last_error_code: string | null
          last_error_detail: string | null
          lease_expires_at: string | null
          lease_owner: string | null
          lease_token_hash: string | null
          model_id: string
          output_artifact_kinds: string[]
          prompt_bundle_version: string
          retry_after: string | null
          run_id: string
          stage: string
          stage_execution_id: string
          started_at: string | null
          status: string
          updated_at: string
          usage_summary: Json
        }
        Insert: {
          attempt_count?: number
          completed_artifact_sha256s?: Json
          completed_at?: string | null
          input_manifest_bucket?: string | null
          input_manifest_path?: string | null
          input_sha256?: string | null
          last_error_code?: string | null
          last_error_detail?: string | null
          lease_expires_at?: string | null
          lease_owner?: string | null
          lease_token_hash?: string | null
          model_id?: string
          output_artifact_kinds?: string[]
          prompt_bundle_version?: string
          retry_after?: string | null
          run_id: string
          stage: string
          stage_execution_id?: string
          started_at?: string | null
          status?: string
          updated_at?: string
          usage_summary?: Json
        }
        Update: {
          attempt_count?: number
          completed_artifact_sha256s?: Json
          completed_at?: string | null
          input_manifest_bucket?: string | null
          input_manifest_path?: string | null
          input_sha256?: string | null
          last_error_code?: string | null
          last_error_detail?: string | null
          lease_expires_at?: string | null
          lease_owner?: string | null
          lease_token_hash?: string | null
          model_id?: string
          output_artifact_kinds?: string[]
          prompt_bundle_version?: string
          retry_after?: string | null
          run_id?: string
          stage?: string
          stage_execution_id?: string
          started_at?: string | null
          status?: string
          updated_at?: string
          usage_summary?: Json
        }
        Relationships: [
          {
            foreignKeyName: "research_pre_research_stage_execution_run_id_fkey"
            columns: ["run_id"]
            isOneToOne: false
            referencedRelation: "research_pre_research_run"
            referencedColumns: ["run_id"]
          },
        ]
      }
      research_pre_research_video_state: {
        Row: {
          created_at: string
          duration_seconds: number | null
          eligibility_status: string
          evaluated_at: string | null
          finished_intent_id: string | null
          finished_transcript_sha256: string | null
          ineligibility_reasons: string[]
          latest_run_id: string | null
          pipeline_status: string
          pre_research_pipeline_finished: boolean
          pre_research_pipeline_finished_at: string | null
          transcript_object_exists: boolean
          transcript_sha256: string | null
          updated_at: string
          video_id: string
        }
        Insert: {
          created_at?: string
          duration_seconds?: number | null
          eligibility_status?: string
          evaluated_at?: string | null
          finished_intent_id?: string | null
          finished_transcript_sha256?: string | null
          ineligibility_reasons?: string[]
          latest_run_id?: string | null
          pipeline_status?: string
          pre_research_pipeline_finished?: boolean
          pre_research_pipeline_finished_at?: string | null
          transcript_object_exists?: boolean
          transcript_sha256?: string | null
          updated_at?: string
          video_id: string
        }
        Update: {
          created_at?: string
          duration_seconds?: number | null
          eligibility_status?: string
          evaluated_at?: string | null
          finished_intent_id?: string | null
          finished_transcript_sha256?: string | null
          ineligibility_reasons?: string[]
          latest_run_id?: string | null
          pipeline_status?: string
          pre_research_pipeline_finished?: boolean
          pre_research_pipeline_finished_at?: string | null
          transcript_object_exists?: boolean
          transcript_sha256?: string | null
          updated_at?: string
          video_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "research_pre_research_video_state_finished_intent_id_fkey"
            columns: ["finished_intent_id"]
            isOneToOne: false
            referencedRelation: "research_ingestion_intent"
            referencedColumns: ["intent_id"]
          },
          {
            foreignKeyName: "research_pre_research_video_state_latest_run_id_fkey"
            columns: ["latest_run_id"]
            isOneToOne: false
            referencedRelation: "research_pre_research_run"
            referencedColumns: ["run_id"]
          },
          {
            foreignKeyName: "research_pre_research_video_state_video_id_fkey"
            columns: ["video_id"]
            isOneToOne: true
            referencedRelation: "research_starter_videos"
            referencedColumns: ["video_id"]
          },
        ]
      }
      research_resource_candidate: {
        Row: {
          analysis_id: string
          confidence: number
          evidence_ids: string[]
          is_first_party: boolean
          license: string | null
          normalized_url: string
          publisher: string | null
          relationship_to_video: string
          resource_candidate_id: string
          resource_type: Database["public"]["Enums"]["research_resource_type"]
          title: string
          url: string
          verification_status: Database["public"]["Enums"]["research_verification_status"]
          why_valuable: string
        }
        Insert: {
          analysis_id: string
          confidence: number
          evidence_ids?: string[]
          is_first_party?: boolean
          license?: string | null
          normalized_url: string
          publisher?: string | null
          relationship_to_video: string
          resource_candidate_id?: string
          resource_type: Database["public"]["Enums"]["research_resource_type"]
          title: string
          url: string
          verification_status: Database["public"]["Enums"]["research_verification_status"]
          why_valuable: string
        }
        Update: {
          analysis_id?: string
          confidence?: number
          evidence_ids?: string[]
          is_first_party?: boolean
          license?: string | null
          normalized_url?: string
          publisher?: string | null
          relationship_to_video?: string
          resource_candidate_id?: string
          resource_type?: Database["public"]["Enums"]["research_resource_type"]
          title?: string
          url?: string
          verification_status?: Database["public"]["Enums"]["research_verification_status"]
          why_valuable?: string
        }
        Relationships: [
          {
            foreignKeyName: "research_resource_candidate_analysis_id_fkey"
            columns: ["analysis_id"]
            isOneToOne: false
            referencedRelation: "research_video_analysis"
            referencedColumns: ["analysis_id"]
          },
        ]
      }
      research_starter_channels: {
        Row: {
          catalog_fetched_at: string | null
          channel_id: string
          channel_url: string | null
          created_at: string
          custom_url: string | null
          description: string | null
          handle: string
          is_primary_research_source: boolean
          metadata: Json
          source: string | null
          subscriber_count: number | null
          thumbnail_url: string | null
          title: string
          transcript_bucket: string
          transcript_path_prefix: string
          updated_at: string
          uploads_playlist_id: string | null
          video_count: number | null
        }
        Insert: {
          catalog_fetched_at?: string | null
          channel_id: string
          channel_url?: string | null
          created_at?: string
          custom_url?: string | null
          description?: string | null
          handle: string
          is_primary_research_source?: boolean
          metadata?: Json
          source?: string | null
          subscriber_count?: number | null
          thumbnail_url?: string | null
          title: string
          transcript_bucket: string
          transcript_path_prefix: string
          updated_at?: string
          uploads_playlist_id?: string | null
          video_count?: number | null
        }
        Update: {
          catalog_fetched_at?: string | null
          channel_id?: string
          channel_url?: string | null
          created_at?: string
          custom_url?: string | null
          description?: string | null
          handle?: string
          is_primary_research_source?: boolean
          metadata?: Json
          source?: string | null
          subscriber_count?: number | null
          thumbnail_url?: string | null
          title?: string
          transcript_bucket?: string
          transcript_path_prefix?: string
          updated_at?: string
          uploads_playlist_id?: string | null
          video_count?: number | null
        }
        Relationships: []
      }
      research_starter_videos: {
        Row: {
          catalog_fetched_at: string | null
          channel_handle: string | null
          channel_id: string | null
          channel_title: string | null
          comment_count: number | null
          created_at: string
          description: string | null
          duration: string | null
          duration_seconds: number | null
          like_count: number | null
          metadata: Json
          pre_research_complete: boolean
          published_at: string | null
          source: string | null
          thumbnail_url: string | null
          title: string
          transcript_bucket: string | null
          transcript_char_count: number | null
          transcript_error: string | null
          transcript_fetched_at: string | null
          transcript_language: string | null
          transcript_path: string | null
          transcript_status: string
          transcript_text: string | null
          updated_at: string
          url: string | null
          video_id: string
          view_count: number | null
        }
        Insert: {
          catalog_fetched_at?: string | null
          channel_handle?: string | null
          channel_id?: string | null
          channel_title?: string | null
          comment_count?: number | null
          created_at?: string
          description?: string | null
          duration?: string | null
          duration_seconds?: number | null
          like_count?: number | null
          metadata?: Json
          pre_research_complete?: boolean
          published_at?: string | null
          source?: string | null
          thumbnail_url?: string | null
          title: string
          transcript_bucket?: string | null
          transcript_char_count?: number | null
          transcript_error?: string | null
          transcript_fetched_at?: string | null
          transcript_language?: string | null
          transcript_path?: string | null
          transcript_status?: string
          transcript_text?: string | null
          updated_at?: string
          url?: string | null
          video_id: string
          view_count?: number | null
        }
        Update: {
          catalog_fetched_at?: string | null
          channel_handle?: string | null
          channel_id?: string | null
          channel_title?: string | null
          comment_count?: number | null
          created_at?: string
          description?: string | null
          duration?: string | null
          duration_seconds?: number | null
          like_count?: number | null
          metadata?: Json
          pre_research_complete?: boolean
          published_at?: string | null
          source?: string | null
          thumbnail_url?: string | null
          title?: string
          transcript_bucket?: string | null
          transcript_char_count?: number | null
          transcript_error?: string | null
          transcript_fetched_at?: string | null
          transcript_language?: string | null
          transcript_path?: string | null
          transcript_status?: string
          transcript_text?: string | null
          updated_at?: string
          url?: string | null
          video_id?: string
          view_count?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "research_starter_videos_channel_id_fkey"
            columns: ["channel_id"]
            isOneToOne: false
            referencedRelation: "research_starter_channels"
            referencedColumns: ["channel_id"]
          },
        ]
      }
      research_taxonomy_version: {
        Row: {
          activated_at: string | null
          created_at: string
          definition_sha256: string
          notes: string | null
          retired_at: string | null
          status: Database["public"]["Enums"]["research_taxonomy_status"]
          taxonomy_version_id: string
          version: string
        }
        Insert: {
          activated_at?: string | null
          created_at?: string
          definition_sha256: string
          notes?: string | null
          retired_at?: string | null
          status?: Database["public"]["Enums"]["research_taxonomy_status"]
          taxonomy_version_id?: string
          version: string
        }
        Update: {
          activated_at?: string | null
          created_at?: string
          definition_sha256?: string
          notes?: string | null
          retired_at?: string | null
          status?: Database["public"]["Enums"]["research_taxonomy_status"]
          taxonomy_version_id?: string
          version?: string
        }
        Relationships: []
      }
      research_video_analysis: {
        Row: {
          analysis_id: string
          challenge_seeds: Json
          concepts: Json
          content_form: Database["public"]["Enums"]["research_content_form"]
          contextualized_abstract: string
          curriculum_roles: string[]
          demonstrations: Json
          difficulty: Database["public"]["Enums"]["research_difficulty"]
          evidence_level: Database["public"]["Enums"]["research_evidence_level"]
          generated_at: string
          initial_summary: string
          key_takeaways: Json
          learning_outcomes: Json
          limitations: Json
          overall_confidence: number
          prerequisites: Json
          quantitative_claims: Json
          run_id: string
          structured_summary: string
          video_id: string
          why_it_matters: string
        }
        Insert: {
          analysis_id?: string
          challenge_seeds?: Json
          concepts?: Json
          content_form: Database["public"]["Enums"]["research_content_form"]
          contextualized_abstract: string
          curriculum_roles?: string[]
          demonstrations?: Json
          difficulty: Database["public"]["Enums"]["research_difficulty"]
          evidence_level: Database["public"]["Enums"]["research_evidence_level"]
          generated_at?: string
          initial_summary: string
          key_takeaways?: Json
          learning_outcomes?: Json
          limitations?: Json
          overall_confidence: number
          prerequisites?: Json
          quantitative_claims?: Json
          run_id: string
          structured_summary: string
          video_id: string
          why_it_matters: string
        }
        Update: {
          analysis_id?: string
          challenge_seeds?: Json
          concepts?: Json
          content_form?: Database["public"]["Enums"]["research_content_form"]
          contextualized_abstract?: string
          curriculum_roles?: string[]
          demonstrations?: Json
          difficulty?: Database["public"]["Enums"]["research_difficulty"]
          evidence_level?: Database["public"]["Enums"]["research_evidence_level"]
          generated_at?: string
          initial_summary?: string
          key_takeaways?: Json
          learning_outcomes?: Json
          limitations?: Json
          overall_confidence?: number
          prerequisites?: Json
          quantitative_claims?: Json
          run_id?: string
          structured_summary?: string
          video_id?: string
          why_it_matters?: string
        }
        Relationships: [
          {
            foreignKeyName: "research_video_analysis_run_id_fkey"
            columns: ["run_id"]
            isOneToOne: true
            referencedRelation: "research_pre_research_run"
            referencedColumns: ["run_id"]
          },
          {
            foreignKeyName: "research_video_analysis_video_id_fkey"
            columns: ["video_id"]
            isOneToOne: false
            referencedRelation: "research_starter_videos"
            referencedColumns: ["video_id"]
          },
        ]
      }
      research_video_category: {
        Row: {
          alternative_rank: number | null
          analysis_id: string
          assignment_role: Database["public"]["Enums"]["research_category_assignment_role"]
          category_code: Database["public"]["Enums"]["research_engineering_category_code"]
          confidence: number
          rationale: string
        }
        Insert: {
          alternative_rank?: number | null
          analysis_id: string
          assignment_role: Database["public"]["Enums"]["research_category_assignment_role"]
          category_code: Database["public"]["Enums"]["research_engineering_category_code"]
          confidence: number
          rationale: string
        }
        Update: {
          alternative_rank?: number | null
          analysis_id?: string
          assignment_role?: Database["public"]["Enums"]["research_category_assignment_role"]
          category_code?: Database["public"]["Enums"]["research_engineering_category_code"]
          confidence?: number
          rationale?: string
        }
        Relationships: [
          {
            foreignKeyName: "research_video_category_analysis_id_fkey"
            columns: ["analysis_id"]
            isOneToOne: false
            referencedRelation: "research_video_analysis"
            referencedColumns: ["analysis_id"]
          },
        ]
      }
      research_video_domain: {
        Row: {
          analysis_id: string
          confidence: number
          domain_code: string
          rationale: string
        }
        Insert: {
          analysis_id: string
          confidence: number
          domain_code: string
          rationale: string
        }
        Update: {
          analysis_id?: string
          confidence?: number
          domain_code?: string
          rationale?: string
        }
        Relationships: [
          {
            foreignKeyName: "research_video_domain_analysis_id_fkey"
            columns: ["analysis_id"]
            isOneToOne: false
            referencedRelation: "research_video_analysis"
            referencedColumns: ["analysis_id"]
          },
          {
            foreignKeyName: "research_video_domain_domain_code_fkey"
            columns: ["domain_code"]
            isOneToOne: false
            referencedRelation: "research_application_domain"
            referencedColumns: ["domain_code"]
          },
        ]
      }
      research_video_initial_summary: {
        Row: {
          ai_concepts: Json
          analysis_id: string
          evidence_ids: string[]
          external_context_notes: Json
          generated_at: string
          research_as_of: string
          software_engineering_concepts: Json
          temporal_context: string
          transcript_summary: string
          video_id: string
        }
        Insert: {
          ai_concepts?: Json
          analysis_id: string
          evidence_ids?: string[]
          external_context_notes?: Json
          generated_at?: string
          research_as_of: string
          software_engineering_concepts?: Json
          temporal_context: string
          transcript_summary: string
          video_id: string
        }
        Update: {
          ai_concepts?: Json
          analysis_id?: string
          evidence_ids?: string[]
          external_context_notes?: Json
          generated_at?: string
          research_as_of?: string
          software_engineering_concepts?: Json
          temporal_context?: string
          transcript_summary?: string
          video_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "research_video_initial_summary_analysis_id_fkey"
            columns: ["analysis_id"]
            isOneToOne: true
            referencedRelation: "research_video_analysis"
            referencedColumns: ["analysis_id"]
          },
          {
            foreignKeyName: "research_video_initial_summary_video_id_fkey"
            columns: ["video_id"]
            isOneToOne: false
            referencedRelation: "research_starter_videos"
            referencedColumns: ["video_id"]
          },
        ]
      }
      research_video_lifecycle: {
        Row: {
          analysis_id: string
          lifecycle_stage: Database["public"]["Enums"]["research_lifecycle_stage"]
        }
        Insert: {
          analysis_id: string
          lifecycle_stage: Database["public"]["Enums"]["research_lifecycle_stage"]
        }
        Update: {
          analysis_id?: string
          lifecycle_stage?: Database["public"]["Enums"]["research_lifecycle_stage"]
        }
        Relationships: [
          {
            foreignKeyName: "research_video_lifecycle_analysis_id_fkey"
            columns: ["analysis_id"]
            isOneToOne: false
            referencedRelation: "research_video_analysis"
            referencedColumns: ["analysis_id"]
          },
        ]
      }
      research_video_technology_summary: {
        Row: {
          analysis_id: string
          confidence: number
          current_status: string
          evidence_ids: string[]
          family_label: string
          family_rank: number
          generated_at: string
          implementations: Json
          official_urls: Json
          primary_technology: string
          primary_technology_kind: string
          related_technologies: Json
          relationship_rationale: string
          research_as_of: string
          role_in_video: string
          summary: string
          technology_summary_id: string
          temporal_status: string
          video_id: string
          video_published_at: string | null
        }
        Insert: {
          analysis_id: string
          confidence: number
          current_status: string
          evidence_ids?: string[]
          family_label: string
          family_rank: number
          generated_at?: string
          implementations?: Json
          official_urls?: Json
          primary_technology: string
          primary_technology_kind: string
          related_technologies?: Json
          relationship_rationale: string
          research_as_of: string
          role_in_video: string
          summary: string
          technology_summary_id?: string
          temporal_status: string
          video_id: string
          video_published_at?: string | null
        }
        Update: {
          analysis_id?: string
          confidence?: number
          current_status?: string
          evidence_ids?: string[]
          family_label?: string
          family_rank?: number
          generated_at?: string
          implementations?: Json
          official_urls?: Json
          primary_technology?: string
          primary_technology_kind?: string
          related_technologies?: Json
          relationship_rationale?: string
          research_as_of?: string
          role_in_video?: string
          summary?: string
          technology_summary_id?: string
          temporal_status?: string
          video_id?: string
          video_published_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "research_video_technology_summary_analysis_id_fkey"
            columns: ["analysis_id"]
            isOneToOne: false
            referencedRelation: "research_video_analysis"
            referencedColumns: ["analysis_id"]
          },
          {
            foreignKeyName: "research_video_technology_summary_video_id_fkey"
            columns: ["video_id"]
            isOneToOne: false
            referencedRelation: "research_starter_videos"
            referencedColumns: ["video_id"]
          },
        ]
      }
      research_web_search_event: {
        Row: {
          provider: string
          query: string
          result_urls: Json
          run_id: string
          search_event_id: string
          search_purpose: string
          searched_at: string
          selected_urls: Json
          subagent: string
        }
        Insert: {
          provider?: string
          query: string
          result_urls?: Json
          run_id: string
          search_event_id?: string
          search_purpose: string
          searched_at?: string
          selected_urls?: Json
          subagent: string
        }
        Update: {
          provider?: string
          query?: string
          result_urls?: Json
          run_id?: string
          search_event_id?: string
          search_purpose?: string
          searched_at?: string
          selected_urls?: Json
          subagent?: string
        }
        Relationships: [
          {
            foreignKeyName: "research_web_search_event_run_id_fkey"
            columns: ["run_id"]
            isOneToOne: false
            referencedRelation: "research_pre_research_run"
            referencedColumns: ["run_id"]
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
      entity_group: {
        Row: {
          created_at: string
          definition: string | null
          entity_kind: string
          exclusion_rules: Json
          id: string
          inclusion_rules: Json
          purpose: string
          review_state: Database["ranking"]["Enums"]["approval_state"]
          slug: string
          tenant_id: string
        }
        Insert: {
          created_at?: string
          definition?: string | null
          entity_kind: string
          exclusion_rules?: Json
          id?: string
          inclusion_rules?: Json
          purpose: string
          review_state?: Database["ranking"]["Enums"]["approval_state"]
          slug: string
          tenant_id?: string
        }
        Update: {
          created_at?: string
          definition?: string | null
          entity_kind?: string
          exclusion_rules?: Json
          id?: string
          inclusion_rules?: Json
          purpose?: string
          review_state?: Database["ranking"]["Enums"]["approval_state"]
          slug?: string
          tenant_id?: string
        }
        Relationships: []
      }
      entity_group_version: {
        Row: {
          created_at: string
          entity_group_id: string
          id: string
          version: number
        }
        Insert: {
          created_at?: string
          entity_group_id: string
          id?: string
          version: number
        }
        Update: {
          created_at?: string
          entity_group_id?: string
          id?: string
          version?: number
        }
        Relationships: [
          {
            foreignKeyName: "entity_group_version_entity_group_id_fkey"
            columns: ["entity_group_id"]
            isOneToOne: false
            referencedRelation: "entity_group"
            referencedColumns: ["id"]
          },
        ]
      }
      feature_definition: {
        Row: {
          created_at: string
          expression: string
          id: string
          inputs: Json
          slug: string
          version: number
        }
        Insert: {
          created_at?: string
          expression: string
          id?: string
          inputs?: Json
          slug: string
          version?: number
        }
        Update: {
          created_at?: string
          expression?: string
          id?: string
          inputs?: Json
          slug?: string
          version?: number
        }
        Relationships: []
      }
      feature_value: {
        Row: {
          computed_at: string
          feature_definition_id: string | null
          id: string
          subject_entity_id: string
          tenant_id: string
          value: number
        }
        Insert: {
          computed_at?: string
          feature_definition_id?: string | null
          id?: string
          subject_entity_id: string
          tenant_id?: string
          value: number
        }
        Update: {
          computed_at?: string
          feature_definition_id?: string | null
          id?: string
          subject_entity_id?: string
          tenant_id?: string
          value?: number
        }
        Relationships: [
          {
            foreignKeyName: "feature_value_feature_definition_id_fkey"
            columns: ["feature_definition_id"]
            isOneToOne: false
            referencedRelation: "feature_definition"
            referencedColumns: ["id"]
          },
        ]
      }
      group_membership: {
        Row: {
          agent_skill_id: string | null
          ai_model_version_id: string | null
          created_at: string
          entity_kind: string | null
          group_version_id: string
          id: string
          library_id: string | null
          mcp_server_id: string | null
          organization_id: string | null
          paper_id: string | null
          person_id: string | null
          product_id: string | null
          provenance_claim_id: string | null
          repository_id: string | null
          valid_from: string
          valid_to: string | null
          video_id: string | null
        }
        Insert: {
          agent_skill_id?: string | null
          ai_model_version_id?: string | null
          created_at?: string
          entity_kind?: string | null
          group_version_id: string
          id?: string
          library_id?: string | null
          mcp_server_id?: string | null
          organization_id?: string | null
          paper_id?: string | null
          person_id?: string | null
          product_id?: string | null
          provenance_claim_id?: string | null
          repository_id?: string | null
          valid_from?: string
          valid_to?: string | null
          video_id?: string | null
        }
        Update: {
          agent_skill_id?: string | null
          ai_model_version_id?: string | null
          created_at?: string
          entity_kind?: string | null
          group_version_id?: string
          id?: string
          library_id?: string | null
          mcp_server_id?: string | null
          organization_id?: string | null
          paper_id?: string | null
          person_id?: string | null
          product_id?: string | null
          provenance_claim_id?: string | null
          repository_id?: string | null
          valid_from?: string
          valid_to?: string | null
          video_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "group_membership_group_version_id_fkey"
            columns: ["group_version_id"]
            isOneToOne: false
            referencedRelation: "entity_group_version"
            referencedColumns: ["id"]
          },
        ]
      }
      leaderboard: {
        Row: {
          created_at: string
          group_version_id: string
          id: string
          policy_version_id: string
          slug: string
          tenant_id: string
        }
        Insert: {
          created_at?: string
          group_version_id: string
          id?: string
          policy_version_id: string
          slug: string
          tenant_id?: string
        }
        Update: {
          created_at?: string
          group_version_id?: string
          id?: string
          policy_version_id?: string
          slug?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "leaderboard_group_version_id_fkey"
            columns: ["group_version_id"]
            isOneToOne: false
            referencedRelation: "entity_group_version"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "leaderboard_policy_version_id_fkey"
            columns: ["policy_version_id"]
            isOneToOne: false
            referencedRelation: "ranking_policy_version"
            referencedColumns: ["id"]
          },
        ]
      }
      leaderboard_edition: {
        Row: {
          edition_no: number
          id: string
          leaderboard_id: string
          published_at: string
          ranking_run_id: string
        }
        Insert: {
          edition_no: number
          id?: string
          leaderboard_id: string
          published_at?: string
          ranking_run_id: string
        }
        Update: {
          edition_no?: number
          id?: string
          leaderboard_id?: string
          published_at?: string
          ranking_run_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "leaderboard_edition_leaderboard_id_fkey"
            columns: ["leaderboard_id"]
            isOneToOne: false
            referencedRelation: "leaderboard"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "leaderboard_edition_ranking_run_id_fkey"
            columns: ["ranking_run_id"]
            isOneToOne: false
            referencedRelation: "ranking_run"
            referencedColumns: ["id"]
          },
        ]
      }
      membership_snapshot: {
        Row: {
          frozen_at: string
          group_version_id: string
          id: string
          member_count: number
          members: Json
        }
        Insert: {
          frozen_at?: string
          group_version_id: string
          id?: string
          member_count: number
          members: Json
        }
        Update: {
          frozen_at?: string
          group_version_id?: string
          id?: string
          member_count?: number
          members?: Json
        }
        Relationships: [
          {
            foreignKeyName: "membership_snapshot_group_version_id_fkey"
            columns: ["group_version_id"]
            isOneToOne: false
            referencedRelation: "entity_group_version"
            referencedColumns: ["id"]
          },
        ]
      }
      metric_definition: {
        Row: {
          description: string | null
          id: string
          name: string
          slug: string
          tenant_id: string
          unit: string | null
        }
        Insert: {
          description?: string | null
          id?: string
          name: string
          slug: string
          tenant_id?: string
          unit?: string | null
        }
        Update: {
          description?: string | null
          id?: string
          name?: string
          slug?: string
          tenant_id?: string
          unit?: string | null
        }
        Relationships: []
      }
      metric_definition_version: {
        Row: {
          definition: Json
          id: string
          metric_definition_id: string
          tenant_id: string
          version: number
        }
        Insert: {
          definition?: Json
          id?: string
          metric_definition_id: string
          tenant_id?: string
          version: number
        }
        Update: {
          definition?: Json
          id?: string
          metric_definition_id?: string
          tenant_id?: string
          version?: number
        }
        Relationships: [
          {
            foreignKeyName: "metric_definition_version_metric_definition_id_fkey"
            columns: ["metric_definition_id"]
            isOneToOne: false
            referencedRelation: "metric_definition"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "metric_definition_version_tenant_id_metric_definition_id_fkey"
            columns: ["tenant_id", "metric_definition_id"]
            isOneToOne: false
            referencedRelation: "metric_definition"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      metric_observation: {
        Row: {
          benchmark_run_id: string | null
          claim_id: string | null
          id: string
          locator_id: string | null
          metric_definition_version_id: string
          observed_at: string
          subject_entity_id: string
          tenant_id: string
          unit: string | null
          value: number
        }
        Insert: {
          benchmark_run_id?: string | null
          claim_id?: string | null
          id?: string
          locator_id?: string | null
          metric_definition_version_id: string
          observed_at: string
          subject_entity_id: string
          tenant_id?: string
          unit?: string | null
          value: number
        }
        Update: {
          benchmark_run_id?: string | null
          claim_id?: string | null
          id?: string
          locator_id?: string | null
          metric_definition_version_id?: string
          observed_at?: string
          subject_entity_id?: string
          tenant_id?: string
          unit?: string | null
          value?: number
        }
        Relationships: [
          {
            foreignKeyName: "metric_observation_metric_definition_version_id_fkey"
            columns: ["metric_definition_version_id"]
            isOneToOne: false
            referencedRelation: "metric_definition_version"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "metric_observation_tenant_id_metric_definition_version_id_fkey"
            columns: ["tenant_id", "metric_definition_version_id"]
            isOneToOne: false
            referencedRelation: "metric_definition_version"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      ranking_policy: {
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
      ranking_policy_version: {
        Row: {
          approval_state: Database["ranking"]["Enums"]["approval_state"]
          created_at: string
          id: string
          penalties: Json
          ranking_policy_id: string
          version: number
          weights: Json
        }
        Insert: {
          approval_state?: Database["ranking"]["Enums"]["approval_state"]
          created_at?: string
          id?: string
          penalties?: Json
          ranking_policy_id: string
          version: number
          weights?: Json
        }
        Update: {
          approval_state?: Database["ranking"]["Enums"]["approval_state"]
          created_at?: string
          id?: string
          penalties?: Json
          ranking_policy_id?: string
          version?: number
          weights?: Json
        }
        Relationships: [
          {
            foreignKeyName: "ranking_policy_version_ranking_policy_id_fkey"
            columns: ["ranking_policy_id"]
            isOneToOne: false
            referencedRelation: "ranking_policy"
            referencedColumns: ["id"]
          },
        ]
      }
      ranking_result: {
        Row: {
          explanation: Json
          id: string
          rank: number
          ranking_run_id: string | null
          score: number | null
          subject_entity_id: string
          tenant_id: string
        }
        Insert: {
          explanation?: Json
          id?: string
          rank: number
          ranking_run_id?: string | null
          score?: number | null
          subject_entity_id: string
          tenant_id?: string
        }
        Update: {
          explanation?: Json
          id?: string
          rank?: number
          ranking_run_id?: string | null
          score?: number | null
          subject_entity_id?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "ranking_result_ranking_run_id_fkey"
            columns: ["ranking_run_id"]
            isOneToOne: false
            referencedRelation: "ranking_run"
            referencedColumns: ["id"]
          },
        ]
      }
      ranking_run: {
        Row: {
          code_ref: string | null
          executed_at: string
          feature_set_hash: string | null
          id: string
          policy_version_id: string
          snapshot_id: string | null
          work_item_id: string | null
        }
        Insert: {
          code_ref?: string | null
          executed_at?: string
          feature_set_hash?: string | null
          id?: string
          policy_version_id: string
          snapshot_id?: string | null
          work_item_id?: string | null
        }
        Update: {
          code_ref?: string | null
          executed_at?: string
          feature_set_hash?: string | null
          id?: string
          policy_version_id?: string
          snapshot_id?: string | null
          work_item_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "ranking_run_policy_version_id_fkey"
            columns: ["policy_version_id"]
            isOneToOne: false
            referencedRelation: "ranking_policy_version"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "ranking_run_snapshot_id_fkey"
            columns: ["snapshot_id"]
            isOneToOne: false
            referencedRelation: "membership_snapshot"
            referencedColumns: ["id"]
          },
        ]
      }
      selection: {
        Row: {
          coverage_rationale: string | null
          created_at: string
          diversity_rationale: string | null
          id: string
          purpose: string
          run_id: string | null
          selected: Json
          tenant_id: string
        }
        Insert: {
          coverage_rationale?: string | null
          created_at?: string
          diversity_rationale?: string | null
          id?: string
          purpose: string
          run_id?: string | null
          selected?: Json
          tenant_id?: string
        }
        Update: {
          coverage_rationale?: string | null
          created_at?: string
          diversity_rationale?: string | null
          id?: string
          purpose?: string
          run_id?: string | null
          selected?: Json
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "selection_run_id_fkey"
            columns: ["run_id"]
            isOneToOne: false
            referencedRelation: "ranking_run"
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
  research: {
    Tables: {
      bundle_artifact: {
        Row: {
          artifact_id: string
          bundle_id: string
          role: string
        }
        Insert: {
          artifact_id: string
          bundle_id: string
          role: string
        }
        Update: {
          artifact_id?: string
          bundle_id?: string
          role?: string
        }
        Relationships: [
          {
            foreignKeyName: "bundle_artifact_bundle_id_fkey"
            columns: ["bundle_id"]
            isOneToOne: false
            referencedRelation: "research_bundle"
            referencedColumns: ["id"]
          },
        ]
      }
      comparison: {
        Row: {
          created_at: string
          dimensions: Json
          entity_ids: string[]
          entity_kind: string
          id: string
          mission_id: string
          title: string
          verdicts: Json
        }
        Insert: {
          created_at?: string
          dimensions?: Json
          entity_ids?: string[]
          entity_kind: string
          id?: string
          mission_id: string
          title: string
          verdicts?: Json
        }
        Update: {
          created_at?: string
          dimensions?: Json
          entity_ids?: string[]
          entity_kind?: string
          id?: string
          mission_id?: string
          title?: string
          verdicts?: Json
        }
        Relationships: []
      }
      downstream_handoff: {
        Row: {
          consumed_at: string | null
          consumed_by_work_item_id: string | null
          created_at: string
          id: string
          mission_id: string
          payload_artifact_id: string | null
          status: string
          target_pipeline: string
        }
        Insert: {
          consumed_at?: string | null
          consumed_by_work_item_id?: string | null
          created_at?: string
          id?: string
          mission_id: string
          payload_artifact_id?: string | null
          status?: string
          target_pipeline: string
        }
        Update: {
          consumed_at?: string | null
          consumed_by_work_item_id?: string | null
          created_at?: string
          id?: string
          mission_id?: string
          payload_artifact_id?: string | null
          status?: string
          target_pipeline?: string
        }
        Relationships: []
      }
      finding: {
        Row: {
          created_at: string
          id: string
          mission_id: string
          proposed_record_kind: string | null
          provenance_claim_id: string | null
          rejection_reason: string | null
          resolution: Database["research"]["Enums"]["finding_resolution"]
          resolved_at: string | null
          resolved_record_id: string | null
          statement: string
          structured: Json | null
          title: string
        }
        Insert: {
          created_at?: string
          id?: string
          mission_id: string
          proposed_record_kind?: string | null
          provenance_claim_id?: string | null
          rejection_reason?: string | null
          resolution?: Database["research"]["Enums"]["finding_resolution"]
          resolved_at?: string | null
          resolved_record_id?: string | null
          statement: string
          structured?: Json | null
          title: string
        }
        Update: {
          created_at?: string
          id?: string
          mission_id?: string
          proposed_record_kind?: string | null
          provenance_claim_id?: string | null
          rejection_reason?: string | null
          resolution?: Database["research"]["Enums"]["finding_resolution"]
          resolved_at?: string | null
          resolved_record_id?: string | null
          statement?: string
          structured?: Json | null
          title?: string
        }
        Relationships: []
      }
      report: {
        Row: {
          created_at: string
          id: string
          mission_id: string | null
          purpose: string
          report_type: string
          slug: string
          tenant_id: string
          title: string
        }
        Insert: {
          created_at?: string
          id?: string
          mission_id?: string | null
          purpose?: string
          report_type?: string
          slug: string
          tenant_id?: string
          title: string
        }
        Update: {
          created_at?: string
          id?: string
          mission_id?: string | null
          purpose?: string
          report_type?: string
          slug?: string
          tenant_id?: string
          title?: string
        }
        Relationships: []
      }
      report_artifact: {
        Row: {
          artifact_id: string
          report_version_id: string
          role: string
          tenant_id: string
        }
        Insert: {
          artifact_id: string
          report_version_id: string
          role: string
          tenant_id?: string
        }
        Update: {
          artifact_id?: string
          report_version_id?: string
          role?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "report_artifact_tenant_id_report_version_id_fkey"
            columns: ["tenant_id", "report_version_id"]
            isOneToOne: false
            referencedRelation: "report_package"
            referencedColumns: ["tenant_id", "report_version_id"]
          },
        ]
      }
      report_assertion: {
        Row: {
          artifact_id: string
          assertion_key: string
          block_pointer: string
          derivation: Json
          end_utf16: number
          id: string
          proposition: string
          qualifiers: Json
          report_version_id: string
          section_id: string
          start_utf16: number
          statement_kind: string
          tenant_id: string
        }
        Insert: {
          artifact_id: string
          assertion_key: string
          block_pointer: string
          derivation?: Json
          end_utf16: number
          id?: string
          proposition: string
          qualifiers?: Json
          report_version_id: string
          section_id: string
          start_utf16: number
          statement_kind: string
          tenant_id?: string
        }
        Update: {
          artifact_id?: string
          assertion_key?: string
          block_pointer?: string
          derivation?: Json
          end_utf16?: number
          id?: string
          proposition?: string
          qualifiers?: Json
          report_version_id?: string
          section_id?: string
          start_utf16?: number
          statement_kind?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "report_assertion_tenant_id_report_version_id_section_id_fkey"
            columns: ["tenant_id", "report_version_id", "section_id"]
            isOneToOne: false
            referencedRelation: "report_section_version"
            referencedColumns: ["tenant_id", "report_version_id", "section_id"]
          },
        ]
      }
      report_assertion_claim: {
        Row: {
          assertion_id: string
          claim_digest: string
          claim_id: string | null
          claim_key: string
          evidence_manifest_artifact_id: string
          report_version_id: string
          role: string
          run_id: string
          tenant_id: string
        }
        Insert: {
          assertion_id: string
          claim_digest: string
          claim_id?: string | null
          claim_key: string
          evidence_manifest_artifact_id: string
          report_version_id: string
          role: string
          run_id: string
          tenant_id?: string
        }
        Update: {
          assertion_id?: string
          claim_digest?: string
          claim_id?: string | null
          claim_key?: string
          evidence_manifest_artifact_id?: string
          report_version_id?: string
          role?: string
          run_id?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "report_assertion_claim_tenant_id_report_version_id_asserti_fkey"
            columns: ["tenant_id", "report_version_id", "assertion_id"]
            isOneToOne: false
            referencedRelation: "report_assertion"
            referencedColumns: ["tenant_id", "report_version_id", "id"]
          },
        ]
      }
      report_claim: {
        Row: {
          claim_id: string
          report_version_id: string
          role: string
          tenant_id: string
        }
        Insert: {
          claim_id: string
          report_version_id: string
          role?: string
          tenant_id?: string
        }
        Update: {
          claim_id?: string
          report_version_id?: string
          role?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "report_claim_report_version_id_fkey"
            columns: ["report_version_id"]
            isOneToOne: false
            referencedRelation: "report_version"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "report_claim_tenant_version_fk"
            columns: ["tenant_id", "report_version_id"]
            isOneToOne: false
            referencedRelation: "report_version"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      report_package: {
        Row: {
          as_of: string
          authoring_mode: string
          created_at: string
          predecessor_version_id: string | null
          producer_attempt_id: string | null
          producer_identity: string
          producer_version: string
          report_id: string
          report_version_id: string
          schema_version: string
          scope: Json
          tenant_id: string
          title: string
        }
        Insert: {
          as_of: string
          authoring_mode: string
          created_at?: string
          predecessor_version_id?: string | null
          producer_attempt_id?: string | null
          producer_identity: string
          producer_version: string
          report_id: string
          report_version_id: string
          schema_version?: string
          scope: Json
          tenant_id?: string
          title: string
        }
        Update: {
          as_of?: string
          authoring_mode?: string
          created_at?: string
          predecessor_version_id?: string | null
          producer_attempt_id?: string | null
          producer_identity?: string
          producer_version?: string
          report_id?: string
          report_version_id?: string
          schema_version?: string
          scope?: Json
          tenant_id?: string
          title?: string
        }
        Relationships: [
          {
            foreignKeyName: "report_package_tenant_id_report_id_predecessor_version_id_fkey"
            columns: ["tenant_id", "report_id", "predecessor_version_id"]
            isOneToOne: false
            referencedRelation: "report_version"
            referencedColumns: ["tenant_id", "report_id", "id"]
          },
          {
            foreignKeyName: "report_package_tenant_id_report_id_report_version_id_fkey"
            columns: ["tenant_id", "report_id", "report_version_id"]
            isOneToOne: false
            referencedRelation: "report_version"
            referencedColumns: ["tenant_id", "report_id", "id"]
          },
        ]
      }
      report_question: {
        Row: {
          coverage: string
          explanation: string
          question: string
          question_key: string
          report_version_id: string
          required: boolean
          resolution_evidence_needed: string | null
          tenant_id: string
        }
        Insert: {
          coverage: string
          explanation: string
          question: string
          question_key: string
          report_version_id: string
          required?: boolean
          resolution_evidence_needed?: string | null
          tenant_id?: string
        }
        Update: {
          coverage?: string
          explanation?: string
          question?: string
          question_key?: string
          report_version_id?: string
          required?: boolean
          resolution_evidence_needed?: string | null
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "report_question_tenant_id_report_version_id_fkey"
            columns: ["tenant_id", "report_version_id"]
            isOneToOne: false
            referencedRelation: "report_package"
            referencedColumns: ["tenant_id", "report_version_id"]
          },
        ]
      }
      report_question_section: {
        Row: {
          question_key: string
          report_version_id: string
          section_id: string
          tenant_id: string
        }
        Insert: {
          question_key: string
          report_version_id: string
          section_id: string
          tenant_id?: string
        }
        Update: {
          question_key?: string
          report_version_id?: string
          section_id?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "report_question_section_tenant_id_report_version_id_questi_fkey"
            columns: ["tenant_id", "report_version_id", "question_key"]
            isOneToOne: false
            referencedRelation: "report_question"
            referencedColumns: [
              "tenant_id",
              "report_version_id",
              "question_key",
            ]
          },
          {
            foreignKeyName: "report_question_section_tenant_id_report_version_id_sectio_fkey"
            columns: ["tenant_id", "report_version_id", "section_id"]
            isOneToOne: false
            referencedRelation: "report_section_version"
            referencedColumns: ["tenant_id", "report_version_id", "section_id"]
          },
        ]
      }
      report_section: {
        Row: {
          id: string
          report_id: string
          section_key: string
          tenant_id: string
        }
        Insert: {
          id?: string
          report_id: string
          section_key: string
          tenant_id?: string
        }
        Update: {
          id?: string
          report_id?: string
          section_key?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "report_section_tenant_id_report_id_fkey"
            columns: ["tenant_id", "report_id"]
            isOneToOne: false
            referencedRelation: "report"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      report_section_dependency: {
        Row: {
          relation: string
          report_version_id: string
          required_section_id: string
          required_version_id: string
          section_id: string
          tenant_id: string
        }
        Insert: {
          relation: string
          report_version_id: string
          required_section_id: string
          required_version_id: string
          section_id: string
          tenant_id?: string
        }
        Update: {
          relation?: string
          report_version_id?: string
          required_section_id?: string
          required_version_id?: string
          section_id?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "report_section_dependency_tenant_id_report_version_id_sect_fkey"
            columns: ["tenant_id", "report_version_id", "section_id"]
            isOneToOne: false
            referencedRelation: "report_section_version"
            referencedColumns: ["tenant_id", "report_version_id", "section_id"]
          },
          {
            foreignKeyName: "report_section_dependency_tenant_id_required_version_id_re_fkey"
            columns: ["tenant_id", "required_version_id", "required_section_id"]
            isOneToOne: false
            referencedRelation: "report_section_version"
            referencedColumns: ["tenant_id", "report_version_id", "section_id"]
          },
        ]
      }
      report_section_version: {
        Row: {
          conclusion: string | null
          content_pointer: string
          context: Json
          heading: string
          ordinal: number
          question: string | null
          report_id: string
          report_version_id: string
          section_id: string
          section_kind: string
          tenant_id: string
        }
        Insert: {
          conclusion?: string | null
          content_pointer: string
          context?: Json
          heading: string
          ordinal: number
          question?: string | null
          report_id: string
          report_version_id: string
          section_id: string
          section_kind: string
          tenant_id?: string
        }
        Update: {
          conclusion?: string | null
          content_pointer?: string
          context?: Json
          heading?: string
          ordinal?: number
          question?: string | null
          report_id?: string
          report_version_id?: string
          section_id?: string
          section_kind?: string
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "report_section_version_tenant_id_report_id_report_version__fkey"
            columns: ["tenant_id", "report_id", "report_version_id"]
            isOneToOne: false
            referencedRelation: "report_package"
            referencedColumns: ["tenant_id", "report_id", "report_version_id"]
          },
          {
            foreignKeyName: "report_section_version_tenant_id_report_id_section_id_fkey"
            columns: ["tenant_id", "report_id", "section_id"]
            isOneToOne: false
            referencedRelation: "report_section"
            referencedColumns: ["tenant_id", "report_id", "id"]
          },
        ]
      }
      report_v2_assertion: {
        Row: {
          assertion_id: string
          assertion_kind: string
          assertion_ref_digest: string
          projected_at: string
          report_id: string
          revision: number
          tenant_id: string
        }
        Insert: {
          assertion_id: string
          assertion_kind: string
          assertion_ref_digest: string
          projected_at?: string
          report_id: string
          revision: number
          tenant_id?: string
        }
        Update: {
          assertion_id?: string
          assertion_kind?: string
          assertion_ref_digest?: string
          projected_at?: string
          report_id?: string
          revision?: number
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "report_v2_assertion_tenant_id_report_id_revision_fkey"
            columns: ["tenant_id", "report_id", "revision"]
            isOneToOne: false
            referencedRelation: "report_v2_revision"
            referencedColumns: ["tenant_id", "report_id", "revision"]
          },
        ]
      }
      report_v2_ingestion: {
        Row: {
          assertion_ref_digest: string | null
          bound_effect_digest: string
          intent_id: string
          outcome: string
          receipt_id: string
          recorded_at: string
          report_id: string
          revision: number
          tenant_id: string
          use_decision_id: string
        }
        Insert: {
          assertion_ref_digest?: string | null
          bound_effect_digest: string
          intent_id: string
          outcome: string
          receipt_id: string
          recorded_at?: string
          report_id: string
          revision: number
          tenant_id?: string
          use_decision_id: string
        }
        Update: {
          assertion_ref_digest?: string | null
          bound_effect_digest?: string
          intent_id?: string
          outcome?: string
          receipt_id?: string
          recorded_at?: string
          report_id?: string
          revision?: number
          tenant_id?: string
          use_decision_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "report_v2_ingestion_tenant_id_report_id_revision_assertion_fkey"
            columns: [
              "tenant_id",
              "report_id",
              "revision",
              "assertion_ref_digest",
            ]
            isOneToOne: false
            referencedRelation: "report_v2_assertion"
            referencedColumns: [
              "tenant_id",
              "report_id",
              "revision",
              "assertion_ref_digest",
            ]
          },
          {
            foreignKeyName: "report_v2_ingestion_tenant_id_report_id_revision_fkey"
            columns: ["tenant_id", "report_id", "revision"]
            isOneToOne: false
            referencedRelation: "report_v2_revision"
            referencedColumns: ["tenant_id", "report_id", "revision"]
          },
        ]
      }
      report_v2_revision: {
        Row: {
          body_digest: string
          domain_report_id: string | null
          projected_at: string
          report_id: string
          report_kind: string
          report_revision_digest: string
          report_revision_id: string
          revision: number
          run_id: string
          tenant_id: string
          verification_snapshot_digest: string
        }
        Insert: {
          body_digest: string
          domain_report_id?: string | null
          projected_at?: string
          report_id: string
          report_kind: string
          report_revision_digest: string
          report_revision_id: string
          revision: number
          run_id: string
          tenant_id?: string
          verification_snapshot_digest: string
        }
        Update: {
          body_digest?: string
          domain_report_id?: string | null
          projected_at?: string
          report_id?: string
          report_kind?: string
          report_revision_digest?: string
          report_revision_id?: string
          revision?: number
          run_id?: string
          tenant_id?: string
          verification_snapshot_digest?: string
        }
        Relationships: [
          {
            foreignKeyName: "report_v2_revision_tenant_id_domain_report_id_fkey"
            columns: ["tenant_id", "domain_report_id"]
            isOneToOne: false
            referencedRelation: "report"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      report_version: {
        Row: {
          assurance_summary: Json
          id: string
          json_artifact_id: string | null
          markdown_artifact_id: string | null
          published_at: string
          report_id: string
          synthesis_consistency_eval_id: string | null
          tenant_id: string
          version: number
        }
        Insert: {
          assurance_summary?: Json
          id?: string
          json_artifact_id?: string | null
          markdown_artifact_id?: string | null
          published_at?: string
          report_id: string
          synthesis_consistency_eval_id?: string | null
          tenant_id?: string
          version: number
        }
        Update: {
          assurance_summary?: Json
          id?: string
          json_artifact_id?: string | null
          markdown_artifact_id?: string | null
          published_at?: string
          report_id?: string
          synthesis_consistency_eval_id?: string | null
          tenant_id?: string
          version?: number
        }
        Relationships: [
          {
            foreignKeyName: "report_version_report_id_fkey"
            columns: ["report_id"]
            isOneToOne: false
            referencedRelation: "report"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "report_version_tenant_report_fk"
            columns: ["tenant_id", "report_id"]
            isOneToOne: false
            referencedRelation: "report"
            referencedColumns: ["tenant_id", "id"]
          },
        ]
      }
      research_bundle: {
        Row: {
          bundle_version: number
          created_at: string
          id: string
          manifest_artifact_id: string | null
          mission_id: string
          status: Database["research"]["Enums"]["bundle_status"]
          tenant_id: string
          updated_at: string
        }
        Insert: {
          bundle_version?: number
          created_at?: string
          id?: string
          manifest_artifact_id?: string | null
          mission_id: string
          status?: Database["research"]["Enums"]["bundle_status"]
          tenant_id?: string
          updated_at?: string
        }
        Update: {
          bundle_version?: number
          created_at?: string
          id?: string
          manifest_artifact_id?: string | null
          mission_id?: string
          status?: Database["research"]["Enums"]["bundle_status"]
          tenant_id?: string
          updated_at?: string
        }
        Relationships: []
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
      read_report_package: {
        Args: { p_report_id: string; p_revision: number; p_tenant: string }
        Returns: {
          assertion_refs: Json
          body: Json
          domain_report_id: string
          ledger: Json
          manifest_index: Json
          renderer_version: string
          report_id: string
          report_kind: string
          report_revision_digest: string
          report_revision_id: string
          revision: number
          run_head_digest: string
          run_id: string
          schema_version: string
          structured_body: Json
          task_id: string
        }[]
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
      bundle_status: "assembling" | "complete" | "failed" | "superseded"
      finding_resolution:
        | "pending"
        | "promoted"
        | "rejected"
        | "deferred"
        | "merged"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  research_private: {
    Tables: {
      [_ in never]: never
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      begin_research_session: {
        Args: { p_eve_session_id: string; p_run_id: string }
        Returns: Json
      }
      begin_synthesis_session: {
        Args: { p_eve_session_id: string; p_run_id: string }
        Returns: Json
      }
      checkpoint_pre_research_stage_input: {
        Args: {
          p_bucket: string
          p_input_sha256: string
          p_lease_token: string
          p_manifest_path: string
          p_prompt_bundle_version: string
          p_run_id: string
          p_stage: string
          p_worker_id: string
        }
        Returns: Database["public"]["Tables"]["research_pre_research_stage_execution"]["Row"]
        SetofOptions: {
          from: "*"
          to: "research_pre_research_stage_execution"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      claim_pre_research_stage: {
        Args: {
          p_lease_seconds?: number
          p_run_id?: string
          p_worker_id: string
        }
        Returns: {
          attempt_count: number
          lease_expires_at: string
          lease_token: string
          output_artifact_kinds: string[]
          run_id: string
          stage: string
          stage_execution_id: string
        }[]
      }
      claim_pre_research_video: {
        Args: {
          p_lease_seconds?: number
          p_model_id?: string
          p_packet_schema_version?: string
          p_prompt_bundle_version?: string
          p_taxonomy_version?: string
          p_video_id?: string
        }
        Returns: Json
      }
      complete_pre_research_stage: {
        Args: {
          p_artifact_sha256s: Json
          p_lease_token: string
          p_next_status?: string
          p_run_id: string
          p_stage: string
          p_usage_summary?: Json
          p_worker_id: string
        }
        Returns: Database["public"]["Tables"]["research_pre_research_stage_execution"]["Row"]
        SetofOptions: {
          from: "*"
          to: "research_pre_research_stage_execution"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      complete_research_phase: {
        Args: { p_eve_session_id: string; p_run_id: string }
        Returns: Json
      }
      complete_synthesis_phase: {
        Args: {
          p_eve_session_id: string
          p_next_status: Database["public"]["Enums"]["research_pre_research_run_status"]
          p_run_id: string
        }
        Returns: Json
      }
      current_transcript_hash: { Args: { p_video_id: string }; Returns: string }
      ensure_pre_research_stage_rows: {
        Args: { p_run_id: string }
        Returns: undefined
      }
      evaluate_pre_research_qualification: {
        Args: {
          p_video: Database["public"]["Tables"]["research_starter_videos"]["Row"]
        }
        Returns: {
          already_finished: boolean
          already_live: boolean
          duration_seconds: number
          eligibility_status: string
          ineligibility_reasons: string[]
          transcript_object_exists: boolean
          transcript_sha256: string
        }[]
      }
      list_finished_pre_research_videos: {
        Args: never
        Returns: {
          analysis_id: string
          duration_seconds: number
          initial_summary: Json
          intent_id: string
          organization_candidates: Json
          packet_storage_prefix: string
          published_at: string
          research_as_of: string
          run_id: string
          technology_summaries: Json
          title: string
          transcript_bucket: string
          transcript_path: string
          transcript_sha256: string
          video_id: string
        }[]
      }
      park_pre_research_stage: {
        Args: {
          p_error_code: string
          p_error_detail: string
          p_lease_token: string
          p_retry_after: string
          p_retryable: boolean
          p_run_id: string
          p_stage: string
          p_worker_id: string
        }
        Returns: Database["public"]["Tables"]["research_pre_research_stage_execution"]["Row"]
        SetofOptions: {
          from: "*"
          to: "research_pre_research_stage_execution"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      project_pre_research_video_state: {
        Args: {
          p_latest_run_id?: string
          p_pipeline_status?: string
          p_video_id: string
        }
        Returns: Database["public"]["Tables"]["research_pre_research_video_state"]["Row"]
        SetofOptions: {
          from: "*"
          to: "research_pre_research_video_state"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      reconcile_pre_research_stage_rows: {
        Args: { p_run_id: string }
        Returns: undefined
      }
      refresh_pre_research_video_qualification: {
        Args: { p_video_id?: string }
        Returns: Json
      }
      touch_pre_research_run: {
        Args: {
          p_error_code?: string
          p_error_detail?: string
          p_intent_path?: string
          p_intent_sha256?: string
          p_lease_seconds?: number
          p_lease_token: string
          p_run_id: string
          p_status?: Database["public"]["Enums"]["research_pre_research_run_status"]
          p_workflow_session_id?: string
        }
        Returns: Database["public"]["Tables"]["research_pre_research_run"]["Row"]
        SetofOptions: {
          from: "*"
          to: "research_pre_research_run"
          isOneToOne: true
          isSetofReturn: false
        }
      }
    }
    Enums: {
      [_ in never]: never
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
          advanced_usage_pattern_id: string | null
          artifact_references: Json
          assurance: string | null
          authority: string | null
          benchmark_result_id: string | null
          channel_explanations: string[]
          claim_id: string | null
          compatibility_constraint_id: string | null
          contradiction_flags: Json
          contradiction_ids: string[]
          coverage_role: string | null
          covered_subquery_ids: string[]
          created_at: string
          failure_mode_id: string | null
          fresh_at: string | null
          freshness: string | null
          graph_paths: Json
          id: string
          implementation_example_id: string | null
          locators: Json
          member_kind: string | null
          member_payload: Json
          member_sha256: string | null
          operational_practice_id: string | null
          packet_id: string
          scores: Json
          search_projection_id: string | null
          security_consideration_id: string | null
          solution_pattern_id: string | null
          source_document_node_id: string | null
          source_representation_id: string | null
          supersedes_ids: string[]
          technical_problem_id: string | null
          tenant_id: string
          vector_item_id: string | null
          verification_state: string | null
        }
        Insert: {
          advanced_usage_pattern_id?: string | null
          artifact_references?: Json
          assurance?: string | null
          authority?: string | null
          benchmark_result_id?: string | null
          channel_explanations?: string[]
          claim_id?: string | null
          compatibility_constraint_id?: string | null
          contradiction_flags?: Json
          contradiction_ids?: string[]
          coverage_role?: string | null
          covered_subquery_ids?: string[]
          created_at?: string
          failure_mode_id?: string | null
          fresh_at?: string | null
          freshness?: string | null
          graph_paths?: Json
          id?: string
          implementation_example_id?: string | null
          locators?: Json
          member_kind?: string | null
          member_payload?: Json
          member_sha256?: string | null
          operational_practice_id?: string | null
          packet_id: string
          scores?: Json
          search_projection_id?: string | null
          security_consideration_id?: string | null
          solution_pattern_id?: string | null
          source_document_node_id?: string | null
          source_representation_id?: string | null
          supersedes_ids?: string[]
          technical_problem_id?: string | null
          tenant_id?: string
          vector_item_id?: string | null
          verification_state?: string | null
        }
        Update: {
          advanced_usage_pattern_id?: string | null
          artifact_references?: Json
          assurance?: string | null
          authority?: string | null
          benchmark_result_id?: string | null
          channel_explanations?: string[]
          claim_id?: string | null
          compatibility_constraint_id?: string | null
          contradiction_flags?: Json
          contradiction_ids?: string[]
          coverage_role?: string | null
          covered_subquery_ids?: string[]
          created_at?: string
          failure_mode_id?: string | null
          fresh_at?: string | null
          freshness?: string | null
          graph_paths?: Json
          id?: string
          implementation_example_id?: string | null
          locators?: Json
          member_kind?: string | null
          member_payload?: Json
          member_sha256?: string | null
          operational_practice_id?: string | null
          packet_id?: string
          scores?: Json
          search_projection_id?: string | null
          security_consideration_id?: string | null
          solution_pattern_id?: string | null
          source_document_node_id?: string | null
          source_representation_id?: string | null
          supersedes_ids?: string[]
          technical_problem_id?: string | null
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
          chunk_id: string | null
          claim_id: string | null
          entity_id: string | null
          id: string
          record_id: string | null
          retired_at: string | null
          summary_id: string | null
          target_kind: string
          tenant_id: string
        }
        Insert: {
          admitted_at?: string
          chunk_id?: string | null
          claim_id?: string | null
          entity_id?: string | null
          id?: string
          record_id?: string | null
          retired_at?: string | null
          summary_id?: string | null
          target_kind: string
          tenant_id?: string
        }
        Update: {
          admitted_at?: string
          chunk_id?: string | null
          claim_id?: string | null
          entity_id?: string | null
          id?: string
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
          document_type_code: string | null
          embedding_item_id: string | null
          end_ms: number | null
          entity_id: string | null
          entity_kind: string | null
          freshness_at: string | null
          generation_run_id: string | null
          id: string
          knowledge_seq: number | null
          language: string | null
          lifecycle: string
          projection_target_id: string | null
          receipt_id: string | null
          retrieval_chunk_id: string | null
          search_projection_id: string | null
          search_text: string | null
          search_tsv: unknown
          secondary_entity_ids: string[]
          source_version_hash: string | null
          space_version_id: string
          start_ms: number | null
          superseded_by_id: string | null
          tenant_id: string
          valid_during: unknown
          verification_state: string
          visibility: string | null
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
          document_type_code?: string | null
          embedding_item_id?: string | null
          end_ms?: number | null
          entity_id?: string | null
          entity_kind?: string | null
          freshness_at?: string | null
          generation_run_id?: string | null
          id?: string
          knowledge_seq?: number | null
          language?: string | null
          lifecycle?: string
          projection_target_id?: string | null
          receipt_id?: string | null
          retrieval_chunk_id?: string | null
          search_projection_id?: string | null
          search_text?: string | null
          search_tsv?: unknown
          secondary_entity_ids?: string[]
          source_version_hash?: string | null
          space_version_id: string
          start_ms?: number | null
          superseded_by_id?: string | null
          tenant_id?: string
          valid_during?: unknown
          verification_state?: string
          visibility?: string | null
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
          document_type_code?: string | null
          embedding_item_id?: string | null
          end_ms?: number | null
          entity_id?: string | null
          entity_kind?: string | null
          freshness_at?: string | null
          generation_run_id?: string | null
          id?: string
          knowledge_seq?: number | null
          language?: string | null
          lifecycle?: string
          projection_target_id?: string | null
          receipt_id?: string | null
          retrieval_chunk_id?: string | null
          search_projection_id?: string | null
          search_text?: string | null
          search_tsv?: unknown
          secondary_entity_ids?: string[]
          source_version_hash?: string | null
          space_version_id?: string
          start_ms?: number | null
          superseded_by_id?: string | null
          tenant_id?: string
          valid_during?: unknown
          verification_state?: string
          visibility?: string | null
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
      project_entity_timeline: { Args: { p_k?: number }; Returns: number }
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
          canonical_schema: string
          canonical_table: string
          code: string
          description: string
          label: string
        }
        Insert: {
          canonical_schema?: string
          canonical_table?: string
          code: string
          description: string
          label?: string
        }
        Update: {
          canonical_schema?: string
          canonical_table?: string
          code?: string
          description?: string
          label?: string
        }
        Relationships: []
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
          specification_id: string | null
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
          specification_id?: string | null
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
          specification_id?: string | null
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
          p_claim?: string
          p_currency?: string
          p_entity: string
          p_extent?: string
          p_payload?: Json
          p_ref_entity?: string
          p_relationship?: string
          p_scope_key?: string
          p_specification?: string
          p_status?: string
          p_stream_kind: string
          p_temporal_basis?: string
          p_unit?: string
          p_valid_during: unknown
        }
        Returns: string
      }
      begin_batch: { Args: { p_expected_head?: number }; Returns: number }
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
      [_ in never]: never
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
      uuidv7: { Args: never; Returns: string }
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
  api: {
    Enums: {},
  },
  content: {
    Enums: {},
  },
  corpus: {
    Enums: {},
  },
  curriculum: {
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
  knowledge: {
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
  knowledge_service: {
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
  provenance: {
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
  research: {
    Enums: {
      bundle_status: ["assembling", "complete", "failed", "superseded"],
      finding_resolution: [
        "pending",
        "promoted",
        "rejected",
        "deferred",
        "merged",
      ],
    },
  },
  research_private: {
    Enums: {},
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
} as const
