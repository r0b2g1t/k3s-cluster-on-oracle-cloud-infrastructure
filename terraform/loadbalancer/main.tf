resource "oci_network_load_balancer_network_load_balancer" "test_network_load_balancer" {
    #Required
    compartment_id = var.compartment_id
    display_name = var.network_load_balancer_display_name
    subnet_id = var.cluster_subnet_id
    is_private = var.network_load_balancer_is_private
    network_security_group_ids = [var.permit_rules_nsg_id]
    nlb_ip_version = var.network_load_balancer_nlb_ip_version

}

resource "oci_network_load_balancer_backend_set" "test_nlb_backend_set_http" {
    name = "test_nlb_backend_80"
    network_load_balancer_id = oci_network_load_balancer_network_load_balancer.test_network_load_balancer.id
    policy = "FIVE_TUPLE"
    ip_version = "IPV4"
    health_checker {
        protocol = "TCP"
        port = "80"
    }
    depends_on = [oci_network_load_balancer_network_load_balancer.test_network_load_balancer]
}

resource "oci_network_load_balancer_backend" "test_nlb_backend_http" {
    count = 3
    backend_set_name = oci_network_load_balancer_backend_set.test_nlb_backend_set_http.name
    network_load_balancer_id = oci_network_load_balancer_network_load_balancer.test_network_load_balancer.id
    port = "80"
    ip_address = "10.0.0.2${count.index}"
    depends_on = [oci_network_load_balancer_backend_set.test_nlb_backend_set_http]
}

resource "oci_network_load_balancer_backend_set" "test_nlb_backend_set_https" {

    name = "test_nlb_backend_443"
    network_load_balancer_id = oci_network_load_balancer_network_load_balancer.test_network_load_balancer.id
    policy = "FIVE_TUPLE"
    ip_version = "IPV4"
    health_checker {
        protocol = "TCP"
        port = 443
    }
    depends_on = [oci_network_load_balancer_network_load_balancer.test_network_load_balancer]
}

resource "oci_network_load_balancer_backend" "test_nlb_backend_https" {
    count = 3
    backend_set_name = oci_network_load_balancer_backend_set.test_nlb_backend_set_https.name
    network_load_balancer_id = oci_network_load_balancer_network_load_balancer.test_network_load_balancer.id
    port = 443
    ip_address = "10.0.0.2${count.index}"
    depends_on = [oci_network_load_balancer_backend_set.test_nlb_backend_set_https]
}


resource "oci_network_load_balancer_backend_set" "test_nlb_backend_set_k8s_api" {
    name = "test_nlb_backend_6443"
    network_load_balancer_id = oci_network_load_balancer_network_load_balancer.test_network_load_balancer.id
    policy = "FIVE_TUPLE"
    ip_version = "IPV4"
    health_checker {
        protocol = "TCP"
        port = 6443
    }
    depends_on = [oci_network_load_balancer_network_load_balancer.test_network_load_balancer]
}

resource "oci_network_load_balancer_backend" "test_nlb_backend_k8s_api" {
    count = 1
    backend_set_name = oci_network_load_balancer_backend_set.test_nlb_backend_set_k8s_api.name
    network_load_balancer_id = oci_network_load_balancer_network_load_balancer.test_network_load_balancer.id
    port = 6443
    ip_address = "10.0.0.2${count.index}"
    depends_on = [oci_network_load_balancer_backend_set.test_nlb_backend_set_k8s_api]
}

resource "oci_network_load_balancer_listener" "test_nlb_listener_http" {
    default_backend_set_name = oci_network_load_balancer_backend_set.test_nlb_backend_set_http.name
    network_load_balancer_id = oci_network_load_balancer_network_load_balancer.test_network_load_balancer.id
    name = "test_nlb_listener_http"
    protocol = "TCP"
    ip_version = "IPV4"
    port = 80
    depends_on = [oci_network_load_balancer_network_load_balancer.test_network_load_balancer]
}

resource "oci_network_load_balancer_listener" "test_nlb_listener_https" {
    default_backend_set_name = oci_network_load_balancer_backend_set.test_nlb_backend_set_https.name
    network_load_balancer_id = oci_network_load_balancer_network_load_balancer.test_network_load_balancer.id
    name = "test_nlb_listener_https"
    protocol = "TCP"
    ip_version = "IPV4"
    port = 443
    depends_on = [oci_network_load_balancer_network_load_balancer.test_network_load_balancer]
}

resource "oci_network_load_balancer_listener" "test_nlb_listener_k8s_api" {
    default_backend_set_name = oci_network_load_balancer_backend_set.test_nlb_backend_set_k8s_api.name
    network_load_balancer_id = oci_network_load_balancer_network_load_balancer.test_network_load_balancer.id
    name = "test_nlb_listener_k8s_api"
    protocol = "TCP"
    ip_version = "IPV4"
    port = 6443
    depends_on = [oci_network_load_balancer_network_load_balancer.test_network_load_balancer]
}