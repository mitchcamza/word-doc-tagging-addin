/*
 * Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */

/* global Office */

Office.onReady(() => {
  // If needed, Office.js is ready to be called.
});

/**
 * Executes when the add-in command is invoked.
 * For Word, insert a simple message into the document and then complete the event.
 * @param event
 */
function action(event: Office.AddinCommands.Event) {
  if (Office.context && Office.context.document && Office.context.document.setSelectedDataAsync) {
    Office.context.document.setSelectedDataAsync(
      "Performed action.",
      { coercionType: Office.CoercionType.Text },
      () => {
        // Be sure to indicate when the add-in command function is complete.
        event.completed();
      }
    );
  } else {
    // If document APIs are not available, just complete the event.
    event.completed();
  }
}

// Register the function with Office.
Office.actions.associate("action", action);
