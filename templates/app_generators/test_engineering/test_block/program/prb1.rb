Flow.create interface: '<%= @namespace %>::Interface' do

  if_job :p1 do
    test :test1, bin: 10, id: :t1

    test :test2, bin: 15, if_failed: :t1
  end

  pass 1, softbin: 55

end
