struct Message: Decodable
{
    let id: UUID
    let role: SenderRole
    let content: String
    let createdAt: Date
    
}
