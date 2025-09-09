'use client'

import * as React from 'react'
import { cn } from '@/lib/utils'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Popover, PopoverContent, PopoverTrigger } from '@/components/ui/popover'
import { Clock } from 'lucide-react'

interface TimePickerInputProps {
  onChange?: (value: string) => void
  placeholder?: string
  className?: string
  disabled?: boolean
  value?: string
}

export function TimePickerInput({
  value = '',
  onChange,
  placeholder = '00:00',
  className,
  disabled,
}: TimePickerInputProps) {
  const [open, setOpen] = React.useState(false)
  const [hours, setHours] = React.useState('00')
  const [minutes, setMinutes] = React.useState('00')

  // Parse initial value
  React.useEffect(() => {
    if (value) {
      const [h, m] = value.split(':')
      setHours(h?.padStart(2, '0') || '00')
      setMinutes(m?.padStart(2, '0') || '00')
    }
  }, [value])

  const handleTimeSelect = (newHours: string, newMinutes: string) => {
    const timeString = `${newHours.padStart(2, '0')}:${newMinutes.padStart(2, '0')}`
    onChange?.(timeString)
    setHours(newHours.padStart(2, '0'))
    setMinutes(newMinutes.padStart(2, '0'))
  }

  const handleHourSelect = (hour: string) => {
    handleTimeSelect(hour, minutes)
  }

  const handleMinuteSelect = (minute: string) => {
    handleTimeSelect(hours, minute)
  }

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const inputValue = e.target.value
    if (inputValue.match(/^\d{0,2}:?\d{0,2}$/)) {
      onChange?.(inputValue)
    }
  }

  const displayValue = value || `${hours}:${minutes}`

  // Generate hour options (00-23)
  const hourOptions = Array.from({ length: 24 }, (_, i) => 
    i.toString().padStart(2, '0')
  )

  // Generate minute options (00-59, in 5-minute increments)
  const minuteOptions = Array.from({ length: 12 }, (_, i) => 
    (i * 5).toString().padStart(2, '0')
  )

  return (
    <Popover open={open} onOpenChange={setOpen}>
      <PopoverTrigger asChild>
        <div className="relative">
          <Input
            value={displayValue}
            onChange={handleInputChange}
            placeholder={placeholder}
            className={cn('w-24 pr-8', className)}
            disabled={disabled}
          />
          <Button
            variant="ghost"
            size="sm"
            className="absolute right-0 top-0 h-full w-8 p-0 hover:bg-transparent"
            disabled={disabled}
            type="button"
            onClick={(e) => {
              e.preventDefault()
              setOpen(!open)
            }}
          >
            <Clock className="h-4 w-4" />
          </Button>
        </div>
      </PopoverTrigger>
      <PopoverContent className="w-auto p-0" align="start">
        <div className="flex">
          {/* Hours */}
          <div className="p-2 border-r">
            <div className="text-xs font-medium text-muted-foreground mb-2 text-center">
              Hours
            </div>
            <div className="grid max-h-[200px] overflow-y-auto">
              {hourOptions.map((hour) => (
                <Button
                  key={hour}
                  variant="ghost"
                  className={cn(
                    'h-8 w-12 p-0 font-normal justify-center text-sm',
                    hours === hour &&
                      'bg-primary text-primary-foreground hover:bg-primary hover:text-primary-foreground'
                  )}
                  onClick={() => handleHourSelect(hour)}
                >
                  {hour}
                </Button>
              ))}
            </div>
          </div>
          
          {/* Minutes */}
          <div className="p-2">
            <div className="text-xs font-medium text-muted-foreground mb-2 text-center">
              Minutes
            </div>
            <div className="grid max-h-[200px] overflow-y-auto">
              {minuteOptions.map((minute) => (
                <Button
                  key={minute}
                  variant="ghost"
                  className={cn(
                    'h-8 w-12 p-0 font-normal justify-center text-sm',
                    minutes === minute &&
                      'bg-primary text-primary-foreground hover:bg-primary hover:text-primary-foreground'
                  )}
                  onClick={() => handleMinuteSelect(minute)}
                >
                  {minute}
                </Button>
              ))}
            </div>
          </div>
        </div>
        
        <div className="p-2 border-t">
          <Button
            size="sm"
            onClick={() => setOpen(false)}
            className="w-full h-8"
          >
            OK
          </Button>
        </div>
      </PopoverContent>
    </Popover>
  )
}