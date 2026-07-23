# UERANSIM Phone Browser

This project adds a real graphical Firefox browser beside each UERANSIM UE
container.  The graphical session is delivered over HTTP, while Firefox sends
web and DNS traffic to an internal SOCKS5 proxy that binds its outbound sockets
to the UE's `uesimtun*` interface.

The split is intentional: routing the entire pod through `uesimtun*` would also
route the remote-display responses into the PDU session and make the UI
unreachable from Kubernetes.

## Image

`ghcr.io/infinitydon/ueransim-phone:v0.1.0`

The image is based on the explicitly versioned
`docker.io/jlesage/firefox:v26.07.2` release. No manifest uses `latest`.

## Add it to a UERANSIM UE

Copy the `phone` container from
`kustomize/ue-deployment-patch.yaml` into the pod template of the UE Deployment
or StatefulSet. Containers in one Kubernetes pod share a network namespace, so
the browser can see the tunnel created by UERANSIM.

The included Kustomize overlay targets the test deployment named
`free5gc-zebra-ueransim-ue`. To adapt it, change the target deployment name and
the Service selector.

```sh
kubectl -n free5gc-zebra-test apply -k kustomize
kubectl -n free5gc-zebra-test port-forward service/ueransim-phone 5800:80
```

Open `http://127.0.0.1:5800`. Firefox is rendered at a 390 by 844 mobile
viewport and uses a mobile user agent.

## Important behavior

- The UI becomes available even while the UE is registering.
- The SOCKS proxy waits for the first IPv4 interface matching
  `UE_TUN_PATTERN`, which defaults to `uesimtun*`.
- Until a PDU session creates that interface, Firefox cannot browse. This is a
  deliberate fail-closed behavior; it cannot silently fall back to `eth0`.
- Firefox sends DNS lookups through SOCKS5, preventing Kubernetes DNS from
  becoming an alternate browsing path.
- One Service may load-balance multiple UE replicas. For strict one-phone to
  one-UE access, create one Service per individually named UE workload or use a
  StatefulSet with per-pod Services.

## Verification

The definitive test is to compare packet counters or capture traffic on the UE
tunnel while loading a page:

```sh
kubectl -n free5gc-zebra-test exec deploy/free5gc-zebra-ueransim-ue \
  -c phone -- ip -s link show uesimtun0
```

The included `tests/verify-tunnel.sh` confirms that the tunnel and local SOCKS
proxy are usable. Run a packet capture on `uesimtun0` for proof that browser
connections traverse the UE data path.

## Security

The Service is ClusterIP by default. Use `kubectl port-forward`, an
authenticated ingress, or enable the base image's HTTPS web authentication
before exposing it outside a trusted network. The integrated terminal and file
manager remain disabled.
