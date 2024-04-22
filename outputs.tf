output "anbox_cloud_subclusters" {
  value = { for name, cluster in module.subcluster : name => cluster.applications }
}
