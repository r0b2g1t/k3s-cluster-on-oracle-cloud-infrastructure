data "oci_objectstorage_namespace" "bucket_namespace" {

    #Optional
    compartment_id = var.compartment_id
}