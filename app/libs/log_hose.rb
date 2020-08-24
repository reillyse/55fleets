class LogHose
  def initialize(machine_id, log_for = nil)
    machine = Machine.find(machine_id)

    machine.logging_until = (Time.now + log_for)
    machine.save!
    Timeout.timeout(log_for) do
      t = Terminal.new machine, 'ubuntu', nil, log_for

      t.connect ["cd deploy && #{machine.pod.log_command} --tail=\"100\" -f"]
    end
  end
end
