import { getOrCreateConversation, getMyConversations, sendMessage, getMessages } from './chatService.js';

export async function startConversation(req, res) {
  try {
    const conversation = await getOrCreateConversation(req.user.id, req.body.otherUserId);
    return res.status(200).json(conversation);
  } catch (err) {
    return res.status(err.status || 500).json({ message: err.message || 'Terjadi kesalahan server' });
  }
}

export async function myConversations(req, res) {
  try {
    const conversations = await getMyConversations(req.user.id);
    return res.status(200).json(conversations);
  } catch (err) {
    return res.status(err.status || 500).json({ message: err.message || 'Terjadi kesalahan server' });
  }
}

export async function postMessage(req, res) {
  try {
    const message = await sendMessage(req.user.id, req.params.conversationId, req.body.content);
    return res.status(201).json(message);
  } catch (err) {
    return res.status(err.status || 500).json({ message: err.message || 'Terjadi kesalahan server' });
  }
}

export async function pollMessages(req, res) {
  try {
    const messages = await getMessages(req.user.id, req.params.conversationId, req.query.since);
    return res.status(200).json(messages);
  } catch (err) {
    return res.status(err.status || 500).json({ message: err.message || 'Terjadi kesalahan server' });
  }
}