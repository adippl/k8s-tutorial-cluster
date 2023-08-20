

gh-k8s-test3-core: cilium-gh-k8s-test3.yaml metallb-config-k8s-test3.yaml priorityClasses.yaml ingress-nginx-admin-test3.yaml ingress-nginx-user-test3.yaml clusterissuer-test3.yaml csi-driver-nfs-storage-class-test3.yaml loki-test3.yaml promtail-test3.yaml prometheus-test3.yaml pgl-test3.yaml 
	scp $^ t3k1:~/
	ssh t3k1 kubectl apply -f priorityClasses.yaml
	#ssh t3k1 kubectl apply -f https://github.com/kubernetes-csi/external-snapshotter/raw/v6.2.2/client/config/crd/snapshot.storage.k8s.io_volumesnapshotclasses.yaml
	#ssh t3k1 kubectl apply -f https://github.com/kubernetes-csi/external-snapshotter/raw/v6.2.2/client/config/crd/snapshot.storage.k8s.io_volumesnapshotcontents.yaml
	#ssh t3k1 kubectl apply -f https://github.com/kubernetes-csi/external-snapshotter/raw/v6.2.2/client/config/crd/snapshot.storage.k8s.io_volumesnapshots.yaml
	ssh t3k1 helm upgrade --install --repo https://kubernetes-sigs.github.io/external-dns/ --create-namespace --namespace external-dns hw-pihole external-dns --version 1.13.0 --values external-dns-pihole-hw-k8s.yaml
	ssh t3k1 helm upgrade --install --repo https://kubernetes-sigs.github.io/external-dns/ --create-namespace --namespace external-dns gh-pihole external-dns --version 1.13.0 --values external-dns-pihole-gh-k8s.yaml
	ssh t3k1 helm upgrade --install --repo https://helm.cilium.io/ --namespace kube-system --create-namespace cilium cilium --version 1.14.1 --values cilium-gh-k8s-test3.yaml
	ssh t3k1 kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
	ssh t3k1 kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.10/config/manifests/metallb-native.yaml
	ssh t3k1 kubectl apply -f metallb-config-k8s-test3.yaml
	ssh t3k1 kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.12.0/cert-manager.yaml
	ssh t3k1 kubectl apply -f clusterissuer-test3.yaml
	ssh t3k1 helm upgrade --install --repo https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/charts csi-nfs csi-driver-nfs --version v4.4.0 --create-namespace --namespace csi-nfs
	ssh t3k1 kubectl apply -f csi-driver-nfs-storage-class-test3.yaml
	ssh t3k1 helm upgrade --install --repo https://grafana.github.io/helm-charts --create-namespace --namespace loki loki loki --version 5.14.1 --values loki-test3.yaml
	ssh t3k1 helm upgrade --install --repo https://grafana.github.io/helm-charts --create-namespace --namespace loki promtail promtail --version 6.14.1 --values promtail-test3.yaml
	ssh t3k1 helm upgrade --install --repo https://prometheus-community.github.io/helm-charts --create-namespace --namespace prometheus prom-stack kube-prometheus-stack --version 48.3.1 --values prometheus-test3.yaml
	ssh t3k1 helm upgrade --install --repo https://kubernetes.github.io/ingress-nginx --namespace admin-ingress-nginx --create-namespace admin ingress-nginx --values ingress-nginx-admin-test3.yaml
	ssh t3k1 helm upgrade --install --repo https://kubernetes.github.io/ingress-nginx --namespace user-ingress-nginx --create-namespace user ingress-nginx --values ingress-nginx-user-test3.yaml
	ssh t3k1 kubectl apply -f pgl-test3.yaml
	ssh t3k1 velero install --provider aws --bucket gh-k8s-test3-backup-velero --plugins velero/velero-plugin-for-aws:v1.7.0 --secret-file velero-gh-k8s-test3  --use-volume-snapshots=false --backup-location-config region=home,s3ForcePathStyle="true",s3Url=https://home.s3.k8s.your.real.domain.on.cloudflare
	ssh t3k1 rm -rf $^



gh-k8s-test3-harbor:
	ssh k1 helm upgrade --install --repo https://helm.goharbor.io --create-namespace --namespace new-harbor harbor harbor --set expose.ingress.controller=user-ingress --set expose.ingress.hosts.core=harbor.k8s-test3.your.real.domain.on.cloudflare --set expose.ingress.annotations."cert-manager\.io/cluster-issuer"=letsencrypt-prod --set expose.ingress.hosts.notary=notary.harbor.k8s-test3.your.real.domain.on.cloudflare --set persistence.persistentVolumeClaim.registry.size=50Gi --set harborAdminPassword=XXXXXXXXXXXXXXXXXXXXXXXXX --set externalURL=https://harbor.k8s-test3.your.real.domain.on.cloudflare
