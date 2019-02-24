require './ptv_stop'

# This is the method that AWS Lamda requires.
# Params from Slack are passed in as event["queryStringParameters"]\
# eg: /tram i need route 69 please would mean event["queryStringParameters"] == "i need route 69 please"
def handler(event:, context:)
  query_string = JSON.generate(event["queryStringParameters"] || '')

  {statusCode: 200, body: JSON.generate(PTVStop.new(query_string).minutes_until_depart)}
end