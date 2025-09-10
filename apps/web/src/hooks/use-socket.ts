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
      console.log('Socket.IO connected:', socket.id)
      setIsConnected(true)
      setConnectionError(null)

      // Join the table room
      socket.emit('join_table', { table_id: tableId })
    })

    socket.on('disconnect', reason => {
      console.log('Socket.IO disconnected:', reason)
      setIsConnected(false)
    })

    socket.on('connect_error', error => {
      console.error('Socket.IO connection error:', error)
      setIsConnected(false)
      setConnectionError(error.message)
    })

    // Table-specific event handlers
    socket.on('room_joined', data => {
      console.log('Joined table room:', data.table_id)
    })

    socket.on('cell_update', data => {
      console.log('Received cell update:', data)
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
