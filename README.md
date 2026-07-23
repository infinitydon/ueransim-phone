# UERANSIM Phone Browser

This project adds a real graphical Chromium browser beside each UERANSIM UE
container. The graphical session is delivered over HTTP, while Chromium sends
web and DNS traffic to an internal SOCKS5 proxy that binds its outbound sockets
to the UE's `uesimtun*` interface.

The split is intentional: routing the entire pod through `uesimtun*` would also
route the remote-display responses into the PDU session and make the UI
unreachable from Kubernetes.

## Image

`ghcr.io/infinitydon/ueransim-phone:v0.2.1`

The egress-proxy image is based on `docker.io/alpine:3.22.1`; the graphical
sidecar uses `lscr.io/linuxserver/chromium:bf9e0b4f-ls46`. No manifest uses
`latest`.

## Add it to a UERANSIM UE

Copy the `phone` and `phone-proxy` containers from
`kustomize/ue-deployment-patch.yaml` into the pod template of the UE Deployment
or StatefulSet. Containers in one Kubernetes pod share a network namespace, so
the browser can see the tunnel created by UERANSIM.

The installer targets the test deployment named
`free5gc-zebra-ueransim-ue` by default. It first removes any older phone
sidecars and then adds the current pair without changing the UE container.

```sh
./scripts/install.sh free5gc-zebra-test free5gc-zebra-ueransim-ue
kubectl -n free5gc-zebra-test port-forward service/ueransim-phone 5843:443
```

Open `https://127.0.0.1:5843`. Chromium is rendered at a 390 by 844 mobile
viewport and uses a mobile user agent.

## Important behavior

- The UI becomes available even while the UE is registering.
- The SOCKS proxy waits for the first IPv4 interface matching
  `UE_TUN_PATTERN`, which defaults to `uesimtun*`.
- Until a PDU session creates that interface, Firefox cannot browse. This is a
  deliberate fail-closed behavior; it cannot silently fall back to `eth0`.
- Chromium sends DNS lookups through SOCKS5, preventing Kubernetes DNS from
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

The image includes `verify-ue-path`, which confirms that the tunnel and local
SOCKS proxy are usable. Run a packet capture on `uesimtun0` for proof that
browser connections traverse the UE data path.

## Security

The Service is ClusterIP by default. Use `kubectl port-forward` or an
authenticated ingress before exposing it outside a trusted network. The
Chromium container is hardened with its terminal, file manager, and sudo access
disabled.
