package permit.debug

import future.keywords.in

import data.permit.custom
import data.permit.debug.abac
import data.permit.debug.rbac
import data.permit.generated.abac.utils
import data.permit.policies
import data.permit.root

default __debug_tenant = null

__debug_tenant = input.resource.tenant {
	utils.has_key(data.tenants, input.resource.tenant)
}

default __debug_action := null

__debug_action = input.action {
	utils.has_key(input, "action")
}

default __debug_user := null

default __debug_user_attributes := {}

__debug_user_attributes = utils.attributes.user

default __debug_user_synced := false

__debug_user_synced = utils.has_key(data.users, input.user.key)

__debug_user = utils.merge_objects(
	input.user,
	{
		"synced": __debug_user_synced,
		"attributes": __debug_user_attributes,
	},
)

default __debug_resource := null

__debug_resource = {
	"type": input.resource.type,
	"attributes": utils.attributes.resource,
}

__debug_details["rbac"] = result {
	# always show rbac debug for rbac allowed requests
	rbac.allow
	result := rbac.details
}

__debug_details["rbac"] = result {
	# show rbac deny debug only if no other model allowed the request
	not rbac.allow
	not abac.allow
	not custom.allow
	result := rbac.details
}

__debug_details["abac"] = result {
	# show abac debug for abac allowed requests
	abac.allow
	result := abac.details
}

__debug_details["abac"] = result {
	# show abac deny debug only if no other model allowed the request and abac is activated
	not rbac.allow
	not custom.allow
	abac.activated
	not abac.allow
	result := abac.details
}

__debug_details["custom"] = result {
	# show custom debug for custom allowed requests
	custom.allow
	result := {
		"allow": custom.allow,
		"code": "custom_policy",
	}
}

default debug := null

debug = utils.merge_objects(
	{"request": {
		"user": __debug_user,
		"tenant": __debug_tenant,
		"action": __debug_action,
		"resource": __debug_resource,
	}},
	__debug_details,
)
