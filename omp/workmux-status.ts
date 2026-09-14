/**
 * Workmux status tracking extension for oh-my-pi.
 *
 * Reports agent status to workmux for tmux window status display.
 * See: https://workmux.raine.dev/guide/status-tracking
 */

import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  let lastStatus: string | undefined;
  let statusQueue = Promise.resolve();

  function writeStatus(status: string) {
    return pi.exec("workmux", ["set-window-status", status]).then(() => {}, () => {});
  }

  function setStatus(status: string) {
    if (status === lastStatus) {
      return statusQueue;
    }
    lastStatus = status;
    statusQueue = statusQueue.then(
      () => writeStatus(status),
      () => writeStatus(status),
    );
    return statusQueue;
  }

  pi.on("session_start", async () => {
    await pi.exec("workmux", ["register-agent"]).catch(() => {});
  });

  pi.on("agent_start", async () => {
    await setStatus("working");
  });

  // Pas de bascule sur `message_end` : un message d'assistant qui porte des
  // appels d'outils termine au milieu du tour, et workmux rend les statuts
  // `waiting`/`done` collants jusqu'a ce qu'on focalise le pane. La fenetre
  // restait donc marquee « attend une reponse » pendant tout le travail.
  // `waiting` vient du seul vrai cas d'attente (l'outil `ask`), `done` de
  // `agent_end`.

  // Un `ask` en cours garde la fenetre en `waiting` : `tool_execution_start`
  // suit immediatement `tool_call` et reposait `working` par-dessus, donc la
  // question n'etait jamais signalee.
  let askPending = false;

  pi.on("tool_call", async (event) => {
    if (event.toolName === "ask") {
      askPending = true;
      await setStatus("waiting");
    } else {
      await setStatus("working");
    }
  });

  pi.on("tool_result", async (event) => {
    if (event.toolName === "ask") {
      askPending = false;
    }
  });

  pi.on("tool_execution_start", async (event) => {
    if (askPending || event.toolName === "ask") {
      return;
    }
    await setStatus("working");
  });

  pi.on("agent_end", async () => {
    if (lastStatus === "done") {
      return;
    }
    lastStatus = "done";
    await writeStatus("done");
  });
}
