/**
 * Ping Status Response of the API
 */
%dw 2.0
var outputPayload = if(vars.dependencyList != null) flatten(vars.dependencyList..payload) else null
fun getDependencyStatus(dependencyResponse) = if(sizeOf(dependencyResponse.status find "UP") == sizeOf(dependencyResponse))
    "OK"
else if (sizeOf(dependencyResponse.status find "DOWN") == sizeOf(dependencyResponse))
    "OFFLINE"
else
    "DEGRADED"
    
output application/json
---
{
	status: if(vars.checkDependencies == true) getDependencyStatus(outputPayload) else "OK",
	apiName: p("api.name") default "",
	apiVersion: p("api.version") default "",
	(dependencies: outputPayload map(item) -> {
		name: item.name default "",
		status: item.status default ""
	})
	if(outputPayload != null)
}