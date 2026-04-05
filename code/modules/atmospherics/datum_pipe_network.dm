/datum/pipe_network
	var/list/datum/gas_mixture/gases = list()
	var/volume = 0

	var/list/obj/machinery/atmospherics/normal_members = list()
	var/list/datum/pipeline/line_members = list()
	var/list/leaks = list()
	var/update = 1

/datum/pipe_network/Destroy()
	STOP_PROCESSING_PIPENET(src)
	for(var/datum/pipeline/line_member in line_members)
		line_member.network = null
	for(var/obj/machinery/atmospherics/normal_member in normal_members)
		normal_member.reassign_network(src, null)
	gases.Cut()
	leaks.Cut()
	normal_members.Cut()
	line_members.Cut()
	return ..()

/datum/pipe_network/Process()
	if(update)
		update = 0
		if(gases.len > 1)
			reconcile_air()

/datum/pipe_network/proc/build_network(obj/machinery/atmospherics/start_normal, obj/machinery/atmospherics/reference)
	if(!start_normal)
		qdel(src)
		return
	start_normal.network_expand(src, reference)

	update_network_gases()

	if((normal_members.len>0)||(line_members.len>0))
		START_PROCESSING_PIPENET(src)
		return 1
	qdel(src)

/datum/pipe_network/proc/merge(datum/pipe_network/giver)
	if(giver==src) return 0

	normal_members |= giver.normal_members

	line_members |= giver.line_members

	leaks |= giver.leaks

	for(var/obj/machinery/atmospherics/normal_member in giver.normal_members)
		normal_member.reassign_network(giver, src)

	for(var/datum/pipeline/line_member in giver.line_members)
		line_member.network = src

	update_network_gases()
	return 1

/datum/pipe_network/proc/update_network_gases()
	//Go through membership roster and make sure gases is up to date

	// Reuse existing list instead of creating new one
	gases.Cut()
	volume = 0

	for(var/obj/machinery/atmospherics/normal_member in normal_members)
		var/datum/gas_mixture/result = normal_member.return_network_air(src)
		if(result)
			gases += result

	for(var/datum/pipeline/line_member in line_members)
		gases += line_member.air

	for(var/datum/gas_mixture/air in gases)
		volume += air.volume

/datum/pipe_network/proc/reconcile_air()
	if(gases.len < 2)
		return
	equalize_gases(gases)
