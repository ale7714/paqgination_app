names = ['The Doctor', 'Gregory House', 'Doug Ross']
300.times do |i|
  Doctor.create( name: "#{names.sample} #{i}")
end