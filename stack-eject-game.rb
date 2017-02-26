# ejection.rb

@@shifter
@@shift_right
@@last_pos

@@score
@@bonus
@@misses

@@display_miss
@@display_air
@@display_section
@game_width

# Initialisation
@score = 0
@bonus = 0
@misses = 0

score_dist = 3

@display_miss = "↓"
@display_bonus = "█"
@display_air   = " "
@display_section = "-"
@game_width = 20
space_width = @game_width - @display_miss.length

def init_layer()
  puts()
  @last_pos = @shifter
  
  @shifter = rand(@game_width - 1) + 1
  @shift_right = true
end

def screen_output(string)
  print("\r#{string}")
end

def input_success()
  held_time_success = 0.1
  tray_close_time = Time.now
  `eject`
  tray_close_held_time = Time.now - tray_close_time
  return tray_close_held_time > held_time_success
end

def print_loss(border_size)
  puts()
  puts(@display_section * border_size)
  puts("GAME OVER!")
  puts("Score: #{@score}")
  puts("Misses: #{@misses}")
end

time_start = Time.now
time_end = Time.now + 30

init_layer()

@last_pos = -165

while true do
  # Block translation
  if @shift_right then
    if @shifter < @game_width - 1 then
      @shifter = @shifter + 1
    else
      @shift_right = false
    end
  else
    if @shifter > 0 then
      @shifter = @shifter - 1
    else
      @shift_right = true
    end
  end
  
  dist = (@shifter - @last_pos).abs
  
  if dist == 0 then 
    # Nailed it!
    display_box = @display_bonus
  elsif dist < score_dist then 
    # Scores
    display_box = (score_dist - dist).to_s
  else
    # Misses
    display_box = @display_miss
  end
  # Game printing
  pre_space_num = space_width - @shifter
  pre_spaces = @display_air * (space_width - pre_space_num)
  post_spaces = @display_air * pre_space_num
  line_game = pre_spaces + display_box + post_spaces
  
  time_remaining = time_end - Time.now
  time_formatted = "%5s" % ('%.2f' % [(time_remaining * 100).round / 100.0])
  line_time = "Time: #{time_formatted}"
  
  score_formatted = "%3s" % @score
  line_score = "Score: #{score_formatted}"
  bonus_formatted = "%2s" % @bonus
  line_bonus = "Bonus: #{bonus_formatted}"
  
  line = line_time + " | " \
         + line_game + " | " \
         + line_score + ", " + line_bonus + " "
  screen_output(line)
  
  # Take disk tray as input, start next layer
  if input_success() then
    init_layer()
    # Scoring
    if dist == 0 then 
      # Nailed it!
      @score = @score + (score_dist - dist) + @bonus
      @bonus = @bonus + 1
    elsif dist < score_dist then 
      # Scores
      @score = @score + (score_dist - dist) + @bonus
    else
      # Misses
      @misses = @misses + 1
      @bonus = [@bonus, 0].max
     end
  end
  
  if time_end < Time.now then
    print_loss(line.length)
  #Countdown
    break
  end 
end

