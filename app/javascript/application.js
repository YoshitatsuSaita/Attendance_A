// app/javascript/application.js
import "@hotwired/turbo-rails";

import { Application } from "@hotwired/stimulus";
const application = Application.start();

import BasicInfoAccordionController from "controllers/basic_info_accordion_controller";
application.register("basic-info-accordion", BasicInfoAccordionController);

import FileInputController from "controllers/file_input_controller";
application.register("file-input", FileInputController);

import OvertimeRequestController from "controllers/overtime_request_controller";
application.register("overtime-request", OvertimeRequestController);

import AttendanceChangeRequestController from "controllers/attendance_change_request_controller";
application.register("attendance-change-request", AttendanceChangeRequestController);

import ApprovalRequestController from "controllers/approval_request_controller";
application.register("approval-request", ApprovalRequestController);
