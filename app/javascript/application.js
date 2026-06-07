// app/javascript/application.js
import "@hotwired/turbo-rails";

import { Application } from "@hotwired/stimulus";
const application = Application.start();

import EditBasicInfoController from "controllers/edit_basic_info_controller";
application.register("edit-basic-info", EditBasicInfoController);

import FileInputController from "controllers/file_input_controller";
application.register("file-input", FileInputController);

import OvertimeRequestController from "controllers/overtime_request_controller";
application.register("overtime-request", OvertimeRequestController);
