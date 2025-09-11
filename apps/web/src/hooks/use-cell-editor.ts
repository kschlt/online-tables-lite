/**
 * Hook for managing cell editing with optimistic updates and debounced saving.
 */

import { useState, useCallback, useRef } from 'react'
import { CellData, CellUpdateRequest, CellBatchUpdateRequest } from '@/types'
import { updateCells } from '@/lib/api'
import { useSocket } from './use-socket'

interface UseCellEditorProps {
  tableId: string
  tableSlug: string
  token: string
  initialCells: CellData[]
}

export function useCellEditor({ tableId, tableSlug, token, initialCells }: UseCellEditorProps) {
  const [cells, setCells] = useState<CellData[]>(initialCells)
  const [pendingUpdates, setPendingUpdates] = useState<Map<string, CellUpdateRequest>>(new Map())
  const [isUpdating, setIsUpdating] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const debounceTimeoutRef = useRef<ReturnType<typeof setTimeout>>()
  const DEBOUNCE_MS = 500

  // Handle real-time cell updates from other clients
  const handleRemoteCellUpdate = useCallback((remoteCells: CellData[]) => {
    setCells(prevCells => {
      const newCells = [...prevCells]

      remoteCells.forEach(remoteCell => {
        const existingIndex = newCells.findIndex(
          c => c.row === remoteCell.row && c.col === remoteCell.col
        )

        if (existingIndex >= 0) {
          if (remoteCell.value === null || remoteCell.value === '') {
            // Remove empty cells
            newCells.splice(existingIndex, 1)
          } else {
            // Update existing cell
            newCells[existingIndex].value = remoteCell.value
          }
        } else if (remoteCell.value !== null && remoteCell.value !== '') {
          // Add new cell
          newCells.push(remoteCell)
        }
      })

      return newCells
    })
  }, [])

  // Socket.IO integration for real-time updates
  const { isConnected, connectionError } = useSocket({
    tableId,
    onCellUpdate: handleRemoteCellUpdate,
  })

  // Get cell value by coordinates
  const getCellValue = useCallback(
    (row: number, col: number): string | null => {
      const cellKey = `${row}-${col}`
      const pendingUpdate = pendingUpdates.get(cellKey)
      if (pendingUpdate) {
        return pendingUpdate.value
      }

      const cell = cells.find(c => c.row === row && c.col === col)
      return cell?.value || null
    },
    [cells, pendingUpdates]
  )

  // Update cell with optimistic update
  const updateCell = useCallback(
    async (row: number, col: number, value: string | null) => {
      const cellKey = `${row}-${col}`

      // Add to pending updates for optimistic UI
      setPendingUpdates(prev => {
        const newMap = new Map(prev)
        newMap.set(cellKey, { row, col, value })
        return newMap
      })

      // Clear existing debounce
      if (debounceTimeoutRef.current) {
        clearTimeout(debounceTimeoutRef.current)
      }

      // Debounce the actual API call
      debounceTimeoutRef.current = setTimeout(async () => {
        try {
          setError(null)
          setIsUpdating(true)

          // Get all pending updates
          const updatesToSend = Array.from(pendingUpdates.values())
          updatesToSend.push({ row, col, value }) // Include current update

          const request: CellBatchUpdateRequest = {
            cells: updatesToSend,
          }

          await updateCells(tableSlug, token, request)

          // Update local state
          setCells(prevCells => {
            const newCells = [...prevCells]

            updatesToSend.forEach(update => {
              const existingIndex = newCells.findIndex(
                c => c.row === update.row && c.col === update.col
              )

              if (existingIndex >= 0) {
                if (update.value === null || update.value === '') {
                  // Remove empty cells
                  newCells.splice(existingIndex, 1)
                } else {
                  // Update existing cell
                  newCells[existingIndex].value = update.value
                }
              } else if (update.value !== null && update.value !== '') {
                // Add new cell
                newCells.push({
                  row: update.row,
                  col: update.col,
                  value: update.value,
                })
              }
            })

            return newCells
          })

          // Clear pending updates
          setPendingUpdates(new Map())
        } catch (err) {
          setError(err instanceof Error ? err.message : 'Failed to update cells')

          // Remove the failed update from pending
          setPendingUpdates(prev => {
            const newMap = new Map(prev)
            newMap.delete(cellKey)
            return newMap
          })
        } finally {
          setIsUpdating(false)
        }
      }, DEBOUNCE_MS)
    },
    [tableSlug, token, pendingUpdates]
  )

  // Sync with external cell updates (from real-time)
  const syncCells = useCallback((newCells: CellData[]) => {
    setCells(newCells)
    // Keep pending updates for optimistic UI
  }, [])

  return {
    getCellValue,
    updateCell,
    syncCells,
    isUpdating,
    error: error || connectionError,
    hasPendingUpdates: pendingUpdates.size > 0,
    isConnected,
  }
}
