class BuildMachineMaintWorker

  include Sidekiq::Worker
  #do this every 20 minutes
  sidekiq_options retry: 0


  def perform
    App.build_system.pods.first.machines.running.order("id desc").select{ |s| s.busy && s.busy < 20.minutes.ago }.map(&:recycle_as_new)
  end
end


#SELECT pg_terminate_backend(22448)

# get all locks that are blocked
# "  SELECT blocked_locks.pid     AS blocked_pid,\n         blocked_activity.usename  AS blocked_user,\n         blocking_locks.pid     AS blocking_pid,\n         blocking_activity.usename AS blocking_user,\n         blocked_activity.query    AS blocked_statement,\n         blocking_activity.query   AS current_statement_in_blocking_process\n   FROM  pg_catalog.pg_locks         blocked_locks\n    JOIN pg_catalog.pg_stat_activity blocked_activity  ON blocked_activity.pid = blocked_locks.pid\n    JOIN pg_catalog.pg_locks         blocking_locks \n        ON blocking_locks.locktype = blocked_locks.locktype\n        AND blocking_locks.DATABASE IS NOT DISTINCT FROM blocked_locks.DATABASE\n        AND blocking_locks.relation IS NOT DISTINCT FROM blocked_locks.relation\n        AND blocking_locks.page IS NOT DISTINCT FROM blocked_locks.page\n        AND blocking_locks.tuple IS NOT DISTINCT FROM blocked_locks.tuple\n        AND blocking_locks.virtualxid IS NOT DISTINCT FROM blocked_locks.virtualxid\n        AND blocking_locks.transactionid IS NOT DISTINCT FROM blocked_locks.transactionid\n        AND blocking_locks.classid IS NOT DISTINCT FROM blocked_locks.classid\n        AND blocking_locks.objid IS NOT DISTINCT FROM blocked_locks.objid\n        AND blocking_locks.objsubid IS NOT DISTINCT FROM blocked_locks.objsubid\n        AND blocking_locks.pid != blocked_locks.pid\n \n    JOIN pg_catalog.pg_stat_activity blocking_activity ON blocking_activity.pid = blocking_locks.pid\n   WHERE NOT blocked_locks.GRANTED;"
