resource "oci_objectstorage_bucket" "bucket" {
    compartment_id = var.compartment_id
    name           = var.bucket
    namespace      = data.oci_objectstorage_namespace.bucket_namespace.namespace

    access_type    = "NoPublicAccess"
    storage_tier   = "Standard"
}
