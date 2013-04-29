spawn      = require("child_process").spawn
wiringpi   = require('node-wiringpi')
thermostat = require('./ThermoStat')
os         = require('os')

RED_LED_PIN = 23
GRN_LED_PIN = 25
BLU_LED_PIN = 4

# Set GRN_LED_PIN to 4 to make it blue
GRN_LED_PIN = 4

MCP_CHANNEL =  0
MCP_FREQUENCY = 100000
TEMP_RATE = parseInt(process.env.TEMP_RATE || 3)
TEMP_CHANNEL = 7

SWITCH_PIN = 24

FAIL = /fail/i
OK   = /ok/i
RECALL = /recall/i

HIGH = wiringpi.WRITE.HIGH
LOW  = wiringpi.WRITE.LOW

exports.RealThermoStat = class RealThermoStat extends thermostat.ThermoStat

  constructor: () ->
    super("raspi.#{os.hostname()}")
    @city = 'San Francisco'
    @country = 'USA'
    @lat  = @jitter_location(37.774929)
    @long = @jitter_location(-122.419416)

  safe_keys: () ->
    keys = super
    keys.push 'city'
    keys.push 'country'
    keys.push 'lat'
    keys.push 'long'
    keys

  init: () ->
    super
    @temp = 0
    @last = {}

  jitter_location: (location) ->
    location += ((Math.random() * 0.1) - 0.05)
    parseFloat(location.toFixed(4))

  process_readings: (readings) ->
    if @last.switch is 0 and readings.switch is 1
      @status = 'FAIL'
    if (!FAIL.test(@last.status)) and FAIL.test(readings.status)
      console.log('failmode')
      wiringpi.digital_write(RED_LED_PIN, HIGH)
      wiringpi.digital_write(GRN_LED_PIN, LOW)
    if (!RECALL.test(@last.status)) and RECALL.test(readings.status)
      console.log('recallmode')
      wiringpi.digital_write(RED_LED_PIN, HIGH)
      wiringpi.digital_write(GRN_LED_PIN, HIGH)
    if (!OK.test(@last.status)) and OK.test(readings.status)
      console.log('allok')
      wiringpi.digital_write(RED_LED_PIN, LOW)
      wiringpi.digital_write(GRN_LED_PIN, HIGH)
    @last = readings

  take_readings: () ->
    readings = super
    readings.city    = @city
    readings.country = @country
    readings.lat = @lat
    readings.long = @long
    readings.switch = wiringpi.digital_read(SWITCH_PIN)
    @process_readings(readings)
    readings

  update: ->
    wiringpi.digital_write( GRN_LED_PIN, LOW );    
    wiringpi.digital_write( RED_LED_PIN, HIGH );    
    wiringpi.digital_write( BLU_LED_PIN, HIGH );    
    git_pull = spawn('git', ['pull'])
    git_pull.stdout.on 'data', (data) -> console.log(data.toString())
    git_pull.stderr.on 'data', (data) -> console.log(data.toString())
    git_pull.on 'close', (code) =>
      console.log "git exit with #{code}"
      wiringpi.digital_write( RED_LED_PIN, LOW );    
      wiringpi.digital_write( BLU_LED_PIN, LOW );    
      process.exit()

  init_board: () ->
    wiringpi.pin_mode( RED_LED_PIN, wiringpi.PIN_MODE.OUTPUT )
    wiringpi.pin_mode( BLU_LED_PIN, wiringpi.PIN_MODE.OUTPUT )
    wiringpi.pin_mode( GRN_LED_PIN, wiringpi.PIN_MODE.OUTPUT )
    wiringpi.digital_write( GRN_LED_PIN, LOW );    
    wiringpi.digital_write( RED_LED_PIN, LOW );    
    wiringpi.digital_write( BLU_LED_PIN, LOW );    
    if(wiringpi.setup_spi(MCP_CHANNEL, MCP_FREQUENCY) == -1)
      console.log("MCP setup error")

    @socket.on 'control-device', (settings) =>
      if settings.green_led?.match(/on/i)
        wiringpi.digital_write( GRN_LED_PIN, HIGH );    
      if settings.green_led?.match(/off/i)
        wiringpi.digital_write( GRN_LED_PIN, LOW );    
      if settings.red_led?.match(/on/i)
        wiringpi.digital_write( RED_LED_PIN, HIGH );    
      if settings.red_led?.match(/off/i)
        wiringpi.digital_write( RED_LED_PIN, LOW );    

  # start the timers
  start: () ->
    super()
    @init_board()
    @start_sample()

  # stop the timers
  stop: () ->
    super()
    clearInterval(@real_sample)

  # vary the temperature
  start_sample: () ->
    # default: (2hrs/36readings)*(sec/hr)*(millis/sec)
    sample = () =>
      mcp_value = wiringpi.mcp_read_channel(MCP_CHANNEL, TEMP_CHANNEL)
      @temp     = ((((mcp_value * ( 3300.0 / 1023.0 )) - 100) / 10.0) - 40.0)
    @real_sample = setInterval(sample, TEMP_RATE * 1000)

(new exports.RealThermoStat).start()
