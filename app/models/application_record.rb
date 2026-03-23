# <rails-lens:schema:begin>
# database_dialect = "PostgreSQL"
# [database_functions]
# functions = [
#   { name = "email", schema = "auth", language = "sql", return_type = "text", description = "Deprecated. Use auth.jwt() -> 'email' instead." },
#   { name = "jwt", schema = "auth", language = "sql", return_type = "jsonb" },
#   { name = "role", schema = "auth", language = "sql", return_type = "text", description = "Deprecated. Use auth.jwt() -> 'role' instead." },
#   { name = "uid", schema = "auth", language = "sql", return_type = "uuid", description = "Deprecated. Use auth.jwt() -> 'sub' instead." },
#   { name = "grant_pg_cron_access", schema = "extensions", language = "plpgsql", return_type = "event_trigger", description = "Grants access to pg_cron" },
#   { name = "grant_pg_graphql_access", schema = "extensions", language = "plpgsql", return_type = "event_trigger", description = "Grants access to pg_graphql" },
#   { name = "grant_pg_net_access", schema = "extensions", language = "plpgsql", return_type = "event_trigger", description = "Grants access to pg_net" },
#   { name = "pgrst_ddl_watch", schema = "extensions", language = "plpgsql", return_type = "event_trigger" },
#   { name = "pgrst_drop_watch", schema = "extensions", language = "plpgsql", return_type = "event_trigger" },
#   { name = "set_graphql_placeholder", schema = "extensions", language = "plpgsql", return_type = "event_trigger", description = "Reintroduces placeholder function for graphql_public.graphql" },
#   { name = "get_auth", schema = "pgbouncer", language = "plpgsql", return_type = "record" },
#   { name = "apply_rls", schema = "realtime", language = "plpgsql", return_type = "realtime.wal_rls" },
#   { name = "broadcast_changes", schema = "realtime", language = "plpgsql", return_type = "void" },
#   { name = "build_prepared_statement_sql", schema = "realtime", language = "sql", return_type = "text" },
#   { name = "cast", schema = "realtime", language = "plpgsql", return_type = "jsonb" },
#   { name = "check_equality_op", schema = "realtime", language = "plpgsql", return_type = "boolean" },
#   { name = "is_visible_through_filters", schema = "realtime", language = "sql", return_type = "boolean" },
#   { name = "list_changes", schema = "realtime", language = "sql", return_type = "realtime.wal_rls" },
#   { name = "quote_wal2json", schema = "realtime", language = "sql", return_type = "text" },
#   { name = "send", schema = "realtime", language = "plpgsql", return_type = "void" },
#   { name = "subscription_check_filters", schema = "realtime", language = "plpgsql", return_type = "trigger" },
#   { name = "to_regrole", schema = "realtime", language = "sql", return_type = "regrole" },
#   { name = "topic", schema = "realtime", language = "sql", return_type = "text" },
#   { name = "can_insert_object", schema = "storage", language = "plpgsql", return_type = "void" },
#   { name = "enforce_bucket_name_length", schema = "storage", language = "plpgsql", return_type = "trigger" },
#   { name = "extension", schema = "storage", language = "plpgsql", return_type = "text" },
#   { name = "filename", schema = "storage", language = "plpgsql", return_type = "text" },
#   { name = "foldername", schema = "storage", language = "plpgsql", return_type = "text[]" },
#   { name = "get_common_prefix", schema = "storage", language = "sql", return_type = "text" },
#   { name = "get_size_by_bucket", schema = "storage", language = "plpgsql", return_type = "record" },
#   { name = "list_multipart_uploads_with_delimiter", schema = "storage", language = "plpgsql", return_type = "record" },
#   { name = "list_objects_with_delimiter", schema = "storage", language = "plpgsql", return_type = "record" },
#   { name = "operation", schema = "storage", language = "plpgsql", return_type = "text" },
#   { name = "protect_delete", schema = "storage", language = "plpgsql", return_type = "trigger" },
#   { name = "search", schema = "storage", language = "plpgsql", return_type = "record" },
#   { name = "search_by_timestamp", schema = "storage", language = "plpgsql", return_type = "record" },
#   { name = "search_v2", schema = "storage", language = "plpgsql", return_type = "record" },
#   { name = "update_updated_at_column", schema = "storage", language = "plpgsql", return_type = "trigger" }
# ]
# <rails-lens:schema:end>
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end
