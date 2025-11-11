%dw 2.0
import * from dw::Runtime
import * from dw::util::Values

fun getExternalId( p, system ) = do {
    var eid = p.externalIds filter ((id, index) -> contains(id.externalIdType,system))
    ---
    if( isEmpty(eid) ) null else eid.externalId[0]
}

fun addExternalId( p, idType, id ) =
    p update {
    	case .externalIds! -> (removeExternalId($,idType) ++ [{
            id: null,
            externalId: id,
            externalIdType: [idType],
            status: "VALID"
        }])
    }

fun removeExternalId( externalIds, idType ) = ( externalIds filter !(contains($.externalIdType, idType)) ) default []

fun mapIds( list, sourceTypeId, destIdType, idMappings, external ) = list map ((p, index) -> do {
    var srcId = getExternalId(p,sourceTypeId) default fail(sourceTypeId ++ " source mapping id missing from payload" ++ write(p,'application/json'))
    var dstId = idMappings[srcId]
    ---
    if( external ) ( if( dstId != null ) addExternalId(p,destIdType,dstId) else p ) else p update "id" with dstId
})

fun convertIdMappingsToMap( idMappings, systemId ) = {(idMappings map ((o, index) -> {
  (o.from.externalId): (o.to filter ((f, index) -> contains(f.externalIdType, systemId) )).externalId[0] default fail("no mapping found for " ++ systemId ++ " : " ++ write( idMappings , 'application/json'))
}))}

fun moveIdToExternalId( record, systemId ) = ( if( record.id != null ) addExternalId( record, systemId, record.id ) else record ) update "id" with null