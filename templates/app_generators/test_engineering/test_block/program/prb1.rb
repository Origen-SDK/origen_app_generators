Flow.create interface: '<%= @namespace %>::Interface' do

  if_job :p1 do
    functional :test1, bin: 10, id: :t1

    functional :test2, bin: 15, if_failed: :t1
  end

end
