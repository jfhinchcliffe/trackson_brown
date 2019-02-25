require 'openssl'
require 'net/http'
require 'json'
require 'time'

class PTVStop
  # Montague St Stop Info (Route 109)
  # stop_id - 2507,
  # route_id - 722,
  # Directions
  # 37 - To City / Box Hill
  # 38 - From City / To Port Melbourne

  # City Road Stop Info (Route 96)
  # stop_id - 2959,
  # route_id - 1041,
  # Directions
  # 35 - To City
  # 36 - From City / To St Kilda

  attr_reader :requested_stop_info

  # Can divine these either via the API or by using the
  # PTV Journey Planner: https://www.ptv.vic.gov.au/route/services/1041/96/
  STOP_INFO = {
    '109': {
      name: 'Montague St Stop (Route 109)',
      stop_id: '2507',
      direction_to_city_id: '37'
    },
    '96': {
      name: 'City Road Stop (Route 96)',
      stop_id: '2959',
      direction_to_city_id: '35'
    }
  }

  def initialize(slack_query = '')
    @requested_stop_info = determine_requested_route(slack_query)
  end

  def minutes_until_depart
    {
      response_type: "in_channel",
      text: "Next trams from #{requested_stop_info[:name]} to the City depart in #{tram_times[0]}, #{tram_times[1]} and #{tram_times[2]}"
    }
  end

  private

  BASE_STOP_URL = "/v3/departures/route_type/1/stop/"
  BASE_URL = 'https://timetableapi.ptv.vic.gov.au'

  DEVELOPER_ID = ENV['DEVID']
  SECURITY_KEY = ENV['KEY']

  # This is where we pull the route out of the submitted slack command - eg /tram 96 or tram route 96 will pull out '96'
  # defaults to Route 109 (Montague St)
  def determine_requested_route(slack_query)
    submitted_text = slack_query.to_s

    return STOP_INFO[:'96'] if submitted_text.include? '96'
    STOP_INFO[:'109']

  rescue NoMethodError
    STOP_INFO[:'109']
  end

  def tram_times
    @tram_times ||= next_departures.map { |departure| calculate_departure_minutes(departure) }
  end

  # Departure Data looks like:
  # {
  #   "stop_id"=>2507,
  #   "route_id"=>722,
  #   "run_id"=>21086,
  #   "direction_id"=>37,
  #   "disruption_ids"=>[],
  #   "scheduled_departure_utc"=>"2019-02-18T11:43:00Z",
  #   "estimated_departure_utc"=>"2019-02-18T11:43:00Z",
  #   "at_platform"=>false,
  #   "platform_number"=>nil,
  #   "flags"=>"S_WCA-RUN_112",
  #   "departure_sequence"=>0
  # }

  def calculate_departure_minutes(departure)
    # Default to scheduled time if estimated isn't there
    departure_time = departure['estimated_departure_utc'] || departure['scheduled_departure_utc']
    seconds_until_depart = Time.parse(departure_time) - Time.now.getutc
    Time.at(seconds_until_depart).utc.strftime("%M min")
  end

  def stop_url
    BASE_STOP_URL + requested_stop_info[:stop_id]
  end

  def direction_id
    requested_stop_info[:direction_to_city_id]
  end

  def next_departures
    get_api_response_for(signed_url)['departures']
  end

  def get_api_response_for(signed_url)
    uri = URI(signed_url)
    JSON.parse(Net::HTTP.get(uri))
  end

  def signed_url
    params_with_dev_id = stop_url + "?devid=#{DEVELOPER_ID}&direction_id=#{requested_stop_info[:direction_to_city_id]}&max_results=3"
    BASE_URL + params + "&signature=#{sign_params(params_with_dev_id)}"
  end

  def sign_params(params)
    OpenSSL::HMAC.hexdigest('sha1',SECURITY_KEY, params).upcase
  end
end

