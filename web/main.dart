// Copyright (c) 2016, Nathan Karasch. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:browser_cli/command_line_interface.dart';
import 'package:browser_cli/process_library.dart';

CommandLineInterface interface;

void main() {
  interface = new CommandLineInterface();
  _registerProcesses();
}

_registerProcesses() {
  interface.processManager.registerProcessFactories([
    new CdProcessFactory(),
    new JobsProcessFactory(),
    new HelpProcessFactory(),
    new LsProcessFactory(),
    new ManProcessFactory(),
    new MkdirProcessFactory(),
    new PrintEnvProcessFactory(),
    new RmProcessFactory(),
    new TestInputProcessFactory()
  ]);
}
