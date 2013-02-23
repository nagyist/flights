exports.schemas = [
{
    "type":"object",
    "$schema": "http://json-schema.org/draft-03/schema",
    "id": "#",
    "required":false,
    "properties":{
        "date": {
            "type":"string",
            "id": "date",
            "required":true
        },
        "flight": {
            "type":"string",
            "id": "flight",
            "required":true
        },
        "price": {
            "type":"string",
            "id": "price",
            "required":true
        },
        "schema_version": {
            "type":"number",
            "id": "schema_version",
            "required":true,
            "enum": [ 2 ]
        },
        "time": {
            "type":"string",
            "id": "time",
            "required":true
        },
        "timestamp": {
            "type":"number",
            "id": "timestamp",
            "required":true
        },
        "type": {
            "type":"string",
            "id": "type",
            "required":true,
            "enum": [ "timetable_item" ]
        }
    }
},
{
    "type":"object",
    "$schema": "http://json-schema.org/draft-03/schema",
    "id": "#",
    "required":false,
    "properties":{
        "airline": {
            "type":"string",
            "id": "airline",
            "required":true
        },
        "destination": {
            "type":"string",
            "id": "destination",
            "required":true
        },
        "flight_id": {
            "type":"string",
            "id": "flight_id",
            "required":true
        },
        "last_status_timestamp": {
            "type":"number",
            "id": "last_status_timestamp",
            "required":true
        },
        "schema_version": {
            "type":"number",
            "id": "schema_version",
            "required":true,
            "enum": [ 2 ]
        },
        "source": {
            "type":"string",
            "id": "source",
            "required":true
        },
        "status": {
            "type":"string",
            "id": "status",
            "required":true,
            "enum": [ "locked", "processed", "error" ]
        },
        "type": {
            "type":"string",
            "id": "type",
            "required":true,
            "enum": [ "flight" ]
        },
        "workers": {
            "type":"array",
            "id": "workers",
            "required":true,
            "items":
            {
                "type":"string",
                "required":false
            },
            "uniqueItems": true
        }
    }
},
{
    "type":"object",
    "$schema": "http://json-schema.org/draft-03/schema",
    "id": "#",
    "required":false,
    "properties":{
        "schema_version": {
            "type":"number",
            "id": "schema_version",
            "required":false,
            "enum": [ 2 ]
        },
        "type": {
            "type":"string",
            "id": "type",
            "enum": [ "airlines" ],
            "required":true
        }
    }
}];
