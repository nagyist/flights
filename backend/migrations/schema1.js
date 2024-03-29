exports.schemas = [{
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
        "destination": {
            "type":"string",
            "id": "destination",
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
            "enum": [ 1 ]
        },
        "source": {
            "type":"string",
            "id": "source",
            "required":true
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
}
];
