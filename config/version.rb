module OrigenAppGenerators
  MAJOR = 1
  MINOR = 0
  BUGFIX = 1
  DEV = nil

  VERSION = [MAJOR, MINOR, BUGFIX].join(".") + (DEV ? ".pre#{DEV}" : '')
end
