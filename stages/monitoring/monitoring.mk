# Main server
ifeq ($(MACHINE_ROLE), production)
monitoring: monitoring_begin wtfd checks prometheus monitoring_end
	@echo "$(ccgreen)Setting up monitoring completed$(ccend)"
else
monitoring: monitoring_begin wtfd checks monitoring_end
	@echo "$(ccgreen)Setting up monitoring completed$(ccend)"
endif

wtfd:
	iac stages/monitoring/configs/wtfd.yaml
	@echo "$(ccgreen)Installing wtfd completed$(ccend)"

checks:
	iac "stages/monitoring/configs/checks_$(MACHINE_ROLE).yaml"
	@echo "$(ccgreen)Installing DAFUQ checks completed$(ccend)"

prometheus:
	iac stages/monitoring/configs/prometheus.yaml
	@echo "$(ccgreen)Installing prometheus completed$(ccend)"

monitoring_begin:
	yamllint stages/monitoring/configs/*.yaml
	iac begin monitoring_stage

monitoring_end:
	iac end monitoring_stage
