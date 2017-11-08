-- Variables --
local version = 0
local contiue = true
local shells = {}

-- Functions --
function center(text, y)
  local w, h = term.getSize()
  local x = ((w/2)-(#text/2))+1
  term.setCursorPos(x, y)
  print(text)
end

function drawBar(y)
    paintutils.drawLine(2, y, 50, y, colors.gray)
end

function drawExit()
    term.setCursorPos(51,1)
    write('x')
end

function startup()
    multishell.setTitle(multishell.getFocus(), "Dashboard")
  _G.tty = {
      [1] = false,
      [2] = false,
      [3] = false,
      [ "get" ] = function()
        for k, v in pairs(_G.tty) do
            if k ~= "latest" then
                if v == false then
                    _G.tty[k] = true
                    return k
                end
            end
        end
        return false
      end,
  }
  term.setBackgroundColor(colors.lightGray)
  term.clear()
  drawExit()
  term.setTextColor(colors.white)
  drawBar(2)
  center('IZT Router | v.' .. version, 2)
  drawBar(5)
  center('Reboot', 5)
  drawBar(8)
  center('Open a new terminal', 8)
  shells["eventViewer"] = multishell.launch({}, shell.resolveProgram("background.lua"))
  multishell.setTitle(shells["eventViewer"], "Event Viewer")

  drawBar(10)
  center("< < < Services > > >", 10)

  drawBar(12)
  center("Network", 12)

  captureClick()
end

function shutdown()
    contiue = false
    for i=2, multishell.getCount() do
        multishell.setFocus(i)
        os.queueEvent("terminate")
    end
    term.setBackgroundColor(colors.black)
    term.clear()
    term.setCursorPos(1,1)
end

function captureClick()
    while contiue do
        local _, button, x, y = os.pullEvent('mouse_click')
        if button == 1 and x==51 and y==1 then
            shutdown()
        elseif button == 1 and x>=2 and x<=50 and y==5 then
            os.reboot()
        elseif button == 1 and x>=2 and x<=50 and y==8 then
            local tty = _G.tty.get()
            if tty == false then
                drawBar(8)
                center("TTY's filled.", 8)
            else
                drawBar(8)
                center('Open a new terminal', 8)
                shells["term" .. tty] = multishell.launch({}, shell.resolveProgram("cli.lua"), tty)
                multishell.setTitle(shells["term" .. tty], "tty" .. tty .. "@" .. os.getComputerID())
                multishell.setFocus(shells["term" .. tty])
            end
        end
    end
end

startup()