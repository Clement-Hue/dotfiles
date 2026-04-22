return {
  {
    "folke/snacks.nvim",
    lazy = false,
    keys = {
      { "<leader>nh", function() require("snacks").notifier.show_history() end, desc = "Notification history" },
    },
    opts = {
      notifier = {
        enabled = true,
        top_down = false,
        margin = { bottom = 2, right = 1 },
        filter = function(notif)
          if type(notif.msg) == "string" and notif.msg:match("^gitlab%.nvim") then
            if notif.msg:match("Could not get draft notes")
              or notif.msg:match("no upstream configured")
              or notif.msg:match("not stored as a remote%-tracking branch") then
              return false
            end
          end
          return true
        end,
      },
    },
  },
}
