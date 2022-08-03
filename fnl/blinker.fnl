(local ns (vim.api.nvim_create_namespace ""))
(var initialized false)
(var options nil)
(var defaults {:count 2
               :duration 100
               :color "white"
               :highlight "BlinkingLine"})

(fn insert_highlights []
  (vim.api.nvim_set_hl 0 "BlinkingLine" {:bg options.color}))

(fn blink_cursorline []
  (if initialized
    (let [bufnr (vim.api.nvim_get_current_buf)
          ; TODO: This isn't perfect, since it counts the gutters, so on wrapped
          ; lines it'll actually go to the next line if line numbers or any
          ; gutter is visible.
          winwidth (vim.api.nvim_win_get_width 0)
          start (vim.api.nvim_win_get_cursor 0)
          startx (- (. start 1) 1)
          start [startx 0]
          finish [startx winwidth]
          on-fn (fn [] (if (vim.api.nvim_buf_is_valid bufnr)
                         (vim.highlight.range
                           bufnr ns options.highlight start finish "V" false)))
          off-fn (fn [] (if (vim.api.nvim_buf_is_valid bufnr)
                          (vim.api.nvim_buf_clear_namespace bufnr ns 0 -1)))
          ]
      (on-fn)
      (vim.defer_fn off-fn options.duration)
      (for [i 2 (* 2 (- options.count 1)) 2]
        (let [delay1 (* i options.duration)
              delay2 (+ delay1 options.duration)]
          (vim.defer_fn on-fn delay1)
          (vim.defer_fn off-fn delay2))))
    (vim.notify "blinker.nvim is not initialized. Call the setup function")))

(fn setup [opts]
  ; Merge opts & defaults into our options
  (set options (vim.tbl_deep_extend :force {} defaults opts))

  ; Set up highlights
  (insert_highlights)

  ; Set up auto command to auto re-setup highlights when the colorscheme changes
  (vim.api.nvim_create_autocmd
    "ColorScheme"
    {:group (vim.api.nvim_create_augroup "BlinkerInitHighlight" {:clear true})
     :callback (fn [] ((. (require "blinker") :insert_highlights)))})

  ; And now we are setup
  (set initialized true))

{: setup
 : blink_cursorline
 : ns
 : initialized
 : insert_highlights
 : options}
