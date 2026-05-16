# Import ID format for aws_scheduler_schedule: group-name/schedule-name
import {
  to = aws_scheduler_schedule.stkz_refresh
  id = "default/stkz-refresh-scheduler-rule"
}

import {
  to = aws_scheduler_schedule.books_refresh
  id = "default/books-refresh-scheduler-rule"
}

import {
  to = aws_scheduler_schedule.zeta_ball_api_pull
  id = "default/zeta-ball-api-pull"
}
