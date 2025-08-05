# Use this set of commands to test the VPC Lattice-based Kubernetes HTTPRoute deployment
# Wait at least 4–5 minutes after deployment before testing, to ensure the route is fully provisioned

# Retrieve all HTTPRoutes created in the cluster
 kubectl get httproute

# Get detailed YAML configuration of a specific HTTPRoute named "color-route"
 kubectl get httproute color-route -o yaml

# Extract the fully qualified domain name (FQDN) assigned by VPC Lattice to the "color-route" HTTPRoute
colorFQDN=$(kubectl get httproute color-route -o json | jq -r '.metadata.annotations."application-networking.k8s.aws/lattice-assigned-domain-name"')

# Print the extracted FQDN so it can be used in testing
 echo "$colorFQDN"

# Execute a curl command from within the "green" deployment pod to send a request to the Lattice-assigned domain
# This simulates service-to-service communication via Lattice
kubectl exec deploy/green -- curl -s $colorFQDN
