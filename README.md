# kubernetes tutorial cluster

This are configuration file for my test k8s cluster. It's half automated
installation script for plugins which I need to have usable kubernetes
cluster. 

Main cluster overview:
* kubernetes version 1.27.3
* Cillium for CNI
* external-dns (exposing dns to pihole)
* MetalLB (l2 mode)
* basic priority classes
* metrics server (serverTLSBootstrap: true)
* ingress-nginx (installs 2 different ingress-classes)
    * admin and user ingress have different IPs for easier filtering
      on external firewall
* cert-manager (dns-01 tls certifcate creation based on CloudFlare dns)
    * every ingress can have TLS
* csi-driver-nfs (basic csi)
* velero backup to external s3 (file system backup)
* loki for log collection
* kube-prometheus-stack for metrics and prom operator
* grafana with multiple data sources (loki, kube-promstack, prometheus)
* prometheus (basic separate instance) 


##configs use 2 domains
###dmz.homelab.domain - your private domain
###your.real.domain.on.cloudflare - real domain managed by Cloudflare
This domain is used to generate TLS via letsencrypt dns01. You can use
external-dns to confiure dna A/AAAA records for this domain in
Cloudflara. I'm using pihole on my network because I don't want to
expose DNS info about my private services.

makefile is just an example how you can apply this config on remote
server. This script sometimes encounters error durring cluster
boottstrap. Some config cannot be loaded before pods validatin it are
fully running. You should be able to just rerun it few times and cluster
should start. 

makefile assumes you have velero is installed via cli program.
