// Javascript functions to enhance SPARQL/Tarql

function toCamel(str) {
    return str.toLowerCase().replace(/\b\w/g, s => s.toUpperCase()).replace(/\s+/g, '');
}

function toIsoDateString(str) {
    return new Date(str + " Z").toISOString().substring(0,10);
}
