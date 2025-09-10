/**
 * Socket.IO client hook for real-time table updates.
 */

import { useEffect, useRef, useState } from 'react'
import { io, Socket } from 'socket.io-client'
import { API_BASE_URL } from '@/constants'
import { CellData } from '@/types'

interface UseSocketProps {
  tableId: string | null
  onCellUpdate?: (_cells: CellData[]) => void
}

export function useSocket({ tableId, onCellUpdate }: UseSocketProps) {
  const socketRef = useRef<Socket | null>(null)
  const [isConnected, setIsConnected] = useState(false)
  const [connectionError, setConnectionError] = useState<string | null>(null)

  useEffect(() => {
    if (!tableId) {
      return
    }

    // Create Socket.IO connection
    const socket = io(API_BASE_URL, {
      transports: ['websocket', 'polling'],
      forceNew: true,
      upgrade: true,
      rememberUpgrade: false,
      timeout: 20000,
    })

    socketRef.current = socket

    // Connection event handlers
    socket.on('connect', () => {
      // Socket.IO connected
      setIsConnected(true)
      setConnectionError(null)

      // Join the table room
      socket.emit('join_table', { table_id: tableId })
    })

    socket.on('disconnect', () => {
      // Socket.IO disconnected
      setIsConnected(false)
    })

    socket.on('connect_error', error => {
      // Socket.IO connection error
      setIsConnected(false)
      setConnectionError(error.message)
    })

    // Table-specific event handlers
    socket.on('room_joined', () => {
      // Joined table room
    })

    socket.on('cell_update', data => {
      // Received cell update
      if (data.table_id === tableId && onCellUpdate && data.cells) {
        onCellUpdate(data.cells)
      }
    })

    // Cleanup on unmount
    return () => {
      socket.emit('leave_table', { table_id: tableId })
      socket.disconnect()
    }
  }, [tableId, onCellUpdate])

  return {
    isConnected,
    connectionError,
    socket: socketRef.current,
  }
}
