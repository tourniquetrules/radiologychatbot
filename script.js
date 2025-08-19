class RadiologyChat {
    constructor() {
        // Get configuration based on current environment
        this.config = window.RadAIConfig.getCurrentConfig();
        this.apiBaseUrl = this.config.apiBaseUrl;
        this.currentModel = 'lingshu-7b';
        this.chatHistory = [];
        this.attachedFile = null;
        
        console.log('RadAI Chat initialized');
        console.log('Current location:', window.location.href);
        console.log('Environment:', this.config.description);
        console.log('API base URL:', this.apiBaseUrl);
        console.log('Using proxy:', this.config.useProxy);
        console.log('Full config:', this.config);
        
        this.initializeElements();
        this.bindEvents();
        this.setupAutoResize();
        this.setupGlobalPaste();
        
        // Test connectivity on startup
        this.testConnectivity();
    }

    buildApiUrl(endpoint) {
        let url;
        if (this.config.useProxy) {
            // For PHP proxy: /api.php?path=v1/models
            url = this.apiBaseUrl + endpoint;
        } else {
            // For direct API: /api/v1/models
            url = this.apiBaseUrl + '/' + endpoint;
        }
        console.log('buildApiUrl:', endpoint, '->', url);
        return url;
    }

    async testConnectivity() {
        try {
            console.log('Testing API connectivity...');
            const apiUrl = this.buildApiUrl('v1/models');
            console.log('Testing URL:', apiUrl);
            
            const response = await fetch(apiUrl, {
                method: 'GET',
                headers: {
                    'Content-Type': 'application/json',
                }
            });
            
            if (response.ok) {
                const data = await response.json();
                console.log('✅ API connectivity test passed');
                console.log(`Found ${data.data.length} models available`);
                
                // Update model dropdown with available models
                this.updateModelOptions(data.data);
            } else {
                console.warn('⚠️ API connectivity test failed:', response.status);
                const errorText = await response.text();
                console.warn('Error response:', errorText);
                this.showConnectivityWarning();
            }
        } catch (error) {
            console.error('❌ API connectivity test error:', error);
            this.showConnectivityWarning();
        }
    }

    updateModelOptions(models) {
        const modelSelect = this.elements.modelSelect;
        const currentModels = ['lingshu-7b'];
        
        // Check if our expected models are available
        const availableModels = models.filter(model => 
            currentModels.includes(model.id)
        );
        
        if (availableModels.length === 0) {
            console.warn('Expected models not found, using first available models');
            // Use first few available models if our expected ones aren't there
            const fallbackModels = models.slice(0, 2);
            if (fallbackModels.length > 0) {
                this.currentModel = fallbackModels[0].id;
                // Update dropdown options here if needed
            }
        }
    }

    showConnectivityWarning() {
        // Add a warning message to the chat
        this.addMessage('assistant', {
            text: '⚠️ **Connection Notice**: There may be connectivity issues with the AI service. If you experience problems, please ensure you are connected to the hospital network or contact IT support.',
            timestamp: new Date()
        });
    }

    initializeElements() {
        this.elements = {
            chatContainer: document.getElementById('chatContainer'),
            messageInput: document.getElementById('messageInput'),
            sendBtn: document.getElementById('sendBtn'),
            attachBtn: document.getElementById('attachBtn'),
            fileInput: document.getElementById('fileInput'),
            modelSelect: document.getElementById('modelSelect'),
            attachmentArea: document.getElementById('attachmentArea'),
            attachedImage: document.getElementById('attachedImage'),
            previewImage: document.getElementById('previewImage'),
            removeAttachment: document.getElementById('removeAttachment'),
            loadingOverlay: document.getElementById('loadingOverlay'),
            errorToast: document.getElementById('errorToast'),
            errorMessage: document.getElementById('errorMessage'),
            closeError: document.getElementById('closeError')
        };
    }

    bindEvents() {
        // Send message events
        this.elements.sendBtn.addEventListener('click', () => this.sendMessage());
        
        // Keyboard events for message input
        this.elements.messageInput.addEventListener('keydown', (e) => {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                this.sendMessage();
            }
        });

        // Enhanced paste event handler for both text and images
        this.elements.messageInput.addEventListener('paste', (e) => {
            console.log('Paste event detected:', e);
            
            // Check if clipboard contains files (images)
            const items = e.clipboardData?.items;
            if (items) {
                for (let i = 0; i < items.length; i++) {
                    const item = items[i];
                    console.log('Clipboard item:', item.type, item.kind);
                    
                    // Handle image paste
                    if (item.type.startsWith('image/')) {
                        console.log('Image detected in clipboard:', item.type);
                        e.preventDefault(); // Prevent default paste behavior for images
                        
                        const file = item.getAsFile();
                        if (file) {
                            console.log('Processing pasted image:', file.name, file.size, file.type);
                            this.handleFileSelection(file);
                            this.showToast('Image pasted successfully! 📋🖼️', 'success');
                            return; // Exit early since we handled the image
                        }
                    }
                }
            }
            
            // Handle text paste (default behavior)
            setTimeout(() => {
                this.updateSendButtonState();
                this.autoResize();
                console.log('Textarea value after paste:', this.elements.messageInput.value);
            }, 10);
        });

        // Handle keyboard shortcuts
        this.elements.messageInput.addEventListener('keydown', (e) => {
            // Allow standard shortcuts (Ctrl+V, Ctrl+A, Ctrl+C, Ctrl+X, etc.)
            if (e.ctrlKey || e.metaKey) {
                // Don't interfere with copy/paste/select operations
                return;
            }
        });

        // Focus event to ensure proper mobile keyboard handling
        this.elements.messageInput.addEventListener('focus', () => {
            // Small delay to ensure mobile keyboard is ready
            setTimeout(() => {
                this.elements.messageInput.scrollIntoView({ behavior: 'smooth', block: 'center' });
            }, 300);
        });

        // Input change event to enable/disable send button
        this.elements.messageInput.addEventListener('input', () => {
            this.updateSendButtonState();
        });

        // File attachment events
        this.elements.attachBtn.addEventListener('click', () => {
            this.elements.fileInput.click();
        });

        this.elements.fileInput.addEventListener('change', (e) => {
            this.handleFileSelection(e.target.files[0]);
        });

        this.elements.removeAttachment.addEventListener('click', () => {
            this.removeAttachment();
        });

        // Model selection
        this.elements.modelSelect.addEventListener('change', (e) => {
            this.currentModel = e.target.value;
            this.showToast(`Switched to ${e.target.value}`, 'info');
        });

        // Error toast close
        this.elements.closeError.addEventListener('click', () => {
            this.hideError();
        });

        // Drag and drop support
        this.setupDragAndDrop();
    }

    setupAutoResize() {
        const textarea = this.elements.messageInput;
        textarea.addEventListener('input', () => {
            this.autoResize();
        });
    }

    autoResize() {
        const textarea = this.elements.messageInput;
        textarea.style.height = 'auto';
        textarea.style.height = Math.min(textarea.scrollHeight, 120) + 'px';
    }

    setupDragAndDrop() {
        const chatContainer = this.elements.chatContainer;

        ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
            chatContainer.addEventListener(eventName, this.preventDefaults, false);
        });

        ['dragenter', 'dragover'].forEach(eventName => {
            chatContainer.addEventListener(eventName, () => {
                chatContainer.classList.add('drag-over');
            }, false);
        });

        ['dragleave', 'drop'].forEach(eventName => {
            chatContainer.addEventListener(eventName, () => {
                chatContainer.classList.remove('drag-over');
            }, false);
        });

        chatContainer.addEventListener('drop', (e) => {
            const files = e.dataTransfer.files;
            if (files.length > 0 && files[0].type.startsWith('image/')) {
                this.handleFileSelection(files[0]);
            }
        }, false);
    }

    preventDefaults(e) {
        e.preventDefault();
        e.stopPropagation();
    }

    setupGlobalPaste() {
        // Global paste handler for the entire document
        document.addEventListener('paste', (e) => {
            // Only handle paste if we're not already in an input field
            const activeElement = document.activeElement;
            const isInputActive = activeElement.tagName === 'INPUT' || 
                                 activeElement.tagName === 'TEXTAREA' || 
                                 activeElement.contentEditable === 'true';
            
            console.log('Global paste event detected. Active element:', activeElement.tagName);
            
            // Check if clipboard contains files (images)
            const items = e.clipboardData?.items;
            if (items) {
                for (let i = 0; i < items.length; i++) {
                    const item = items[i];
                    
                    // Handle image paste
                    if (item.type.startsWith('image/')) {
                        console.log('Image detected in global paste:', item.type);
                        e.preventDefault(); // Prevent default paste behavior for images
                        
                        const file = item.getAsFile();
                        if (file) {
                            console.log('Processing globally pasted image:', file.name, file.size, file.type);
                            this.handleFileSelection(file);
                            this.showToast('Image pasted successfully! 📋🖼️', 'success');
                            
                            // Focus the message input to show the user where they can type
                            this.elements.messageInput.focus();
                            
                            return; // Exit early since we handled the image
                        }
                    }
                }
            }
        });
    }

    updateSendButtonState() {
        const hasText = this.elements.messageInput.value.trim().length > 0;
        const hasAttachment = this.attachedFile !== null;
        this.elements.sendBtn.disabled = !hasText && !hasAttachment;
    }

    handleFileSelection(file) {
        if (!file) return;

        if (!file.type.startsWith('image/')) {
            this.showError('Please select an image file.');
            return;
        }

        if (file.size > 10 * 1024 * 1024) { // 10MB limit
            this.showError('Image file size should be less than 10MB.');
            return;
        }

        this.attachedFile = file;
        
        const reader = new FileReader();
        reader.onload = (e) => {
            this.elements.previewImage.src = e.target.result;
            this.elements.attachmentArea.style.display = 'block';
            this.updateSendButtonState();
        };
        reader.readAsDataURL(file);

        // Clear file input
        this.elements.fileInput.value = '';
    }

    removeAttachment() {
        this.attachedFile = null;
        this.elements.attachmentArea.style.display = 'none';
        this.elements.previewImage.src = '';
        this.updateSendButtonState();
    }

    async sendMessage() {
        const messageText = this.elements.messageInput.value.trim();
        
        if (!messageText && !this.attachedFile) {
            return;
        }

        // Clear input and disable send button
        this.elements.messageInput.value = '';
        this.elements.messageInput.style.height = 'auto';
        this.elements.sendBtn.disabled = true;

        // Prepare message data
        const messageData = {
            text: messageText,
            image: this.attachedFile ? await this.fileToBase64(this.attachedFile) : null,
            imageType: this.attachedFile ? this.attachedFile.type : null,
            timestamp: new Date()
        };

        // Add user message to chat
        this.addMessage('user', messageData);

        // Store attachment reference and clear it
        const hadAttachment = this.attachedFile !== null;
        if (hadAttachment) {
            this.removeAttachment();
        }

        // Show loading
        this.showLoading();

        try {
            // Send to API
            const response = await this.callAPI(messageData);
            this.addMessage('assistant', {
                text: response,
                timestamp: new Date()
            });
        } catch (error) {
            console.error('API Error:', error);
            this.showError('Failed to get response from AI model. Please try again.');
            this.addMessage('assistant', {
                text: 'I apologize, but I encountered an error processing your request. Please check your connection and try again.',
                timestamp: new Date()
            });
        } finally {
            this.hideLoading();
            this.updateSendButtonState();
        }
    }

    async fileToBase64(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onload = () => resolve(reader.result.split(',')[1]);
            reader.onerror = reject;
            reader.readAsDataURL(file);
        });
    }

    async callAPI(messageData) {
        const messages = [
            {
                role: 'system',
                content: 'You are a highly knowledgeable and helpful AI assistant specialized in radiology and medical imaging. When given a medical image or question, analyze the case step-by-step using sequential reasoning. Clearly describe your thought process, observations, and possible diagnoses. Always explain your reasoning, mention relevant anatomical structures, and suggest next steps or further investigations if appropriate. If an image is provided, interpret it in detail. Remember, your analysis is for informational purposes and should not replace professional medical advice.'
            }
        ];

        // Add chat history context (last 10 messages)
        const recentHistory = this.chatHistory.slice(-10);
        recentHistory.forEach(msg => {
            if (msg.role === 'user') {
                let content = msg.content.text || '';
                
                if (msg.content.image) {
                    // Format historical message with image for Vision API
                    messages.push({
                        role: 'user',
                        content: [
                            {
                                type: 'text',
                                text: content
                            },
                            {
                                type: 'image_url',
                                image_url: {
                                    url: `data:image/png;base64,${msg.content.image}`,
                                    detail: "high"
                                }
                            }
                        ]
                    });
                } else {
                    // Text-only historical message
                    messages.push({
                        role: 'user',
                        content: content
                    });
                }
            } else {
                messages.push({
                    role: 'assistant',
                    content: msg.content.text
                });
            }
        });

        // Add current message
        let currentContent = messageData.text || 'Please analyze this medical image.';
        
        // Format message with image if present
        let userMessage;
        if (messageData.image) {
            // Use the correct MIME type from the original file
            const mimeType = messageData.imageType || 'image/png';
            
            // Format for LM Studio - try the exact format LM Studio web interface uses
            userMessage = {
                role: 'user',
                content: [
                    {
                        type: 'text',
                        text: currentContent
                    },
                    {
                        type: 'image_url',
                        image_url: {
                            url: `data:${mimeType};base64,${messageData.image}`,
                            detail: "high"
                        }
                    }
                ]
            };
        } else {
            // Text-only message
            userMessage = {
                role: 'user',
                content: currentContent
            };
        }

        messages.push(userMessage);

        const requestBody = {
            model: this.currentModel,
            messages: messages,
            max_tokens: 1000,
            temperature: 0.7,
            stream: false,
            tools: [
                {
                    type: "function",
                    function: {
                        name: "sequential_thinking",
                        description: "Use this tool to think through complex problems step by step, especially for medical image analysis",
                        parameters: {
                            type: "object",
                            properties: {
                                thinking: {
                                    type: "string",
                                    description: "Your step-by-step thinking process for analyzing the medical image or question"
                                }
                            },
                            required: ["thinking"]
                        }
                    }
                }
            ],
            tool_choice: messageData.image ? "auto" : "none"  // Only use tools when there's an image
        };

        console.log('Making API request to:', this.buildApiUrl('v1/chat/completions'));
        console.log('Has image data:', messageData.image ? 'Yes' : 'No');
        if (messageData.image) {
            console.log('Image data length:', messageData.image.length);
            console.log('Image data preview:', messageData.image.substring(0, 100) + '...');
        }
        console.log('Full request body:', JSON.stringify(requestBody, null, 2));

        try {
            const response = await fetch(this.buildApiUrl('v1/chat/completions'), {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(requestBody)
            });

            console.log('API response status:', response.status);

            if (!response.ok) {
                const errorText = await response.text();
                console.error('API error response:', errorText);
                throw new Error(`HTTP error! status: ${response.status} - ${errorText}`);
            }

            const data = await response.json();
            console.log('API response data:', data);
            
            if (!data.choices || !data.choices[0] || !data.choices[0].message) {
                throw new Error('Invalid response format from API');
            }

            const message = data.choices[0].message;
            
            // Check if the model made tool calls
            if (message.tool_calls && message.tool_calls.length > 0) {
                console.log('Tool calls detected:', message.tool_calls);
                
                // For sequential thinking, we'll combine the tool call with the content
                let responseContent = message.content || '';
                
                for (const toolCall of message.tool_calls) {
                    if (toolCall.function && toolCall.function.name === 'sequential_thinking') {
                        const thinking = JSON.parse(toolCall.function.arguments).thinking;
                        responseContent = `**Sequential Analysis:**\n\n${thinking}\n\n${responseContent}`;
                    }
                }
                
                return responseContent;
            }

            return message.content;

        } catch (error) {
            console.error('API call failed:', error);
            
            // If this is a CORS error when accessing externally, show helpful message
            if (error.message.includes('CORS') || error.message.includes('Network')) {
                throw new Error('Network connectivity issue. Please ensure you are connected to the hospital network or contact IT support.');
            }
            
            throw error;
        }
    }

    addMessage(role, content) {
        // Store in chat history
        this.chatHistory.push({ role, content });

        // Remove welcome message if it exists
        const welcomeMessage = this.elements.chatContainer.querySelector('.welcome-message');
        if (welcomeMessage) {
            welcomeMessage.remove();
        }

        // Create message element
        const messageDiv = document.createElement('div');
        messageDiv.className = `message ${role}`;

        const avatarDiv = document.createElement('div');
        avatarDiv.className = 'message-avatar';
        avatarDiv.innerHTML = role === 'user' ? '<i class="fas fa-user"></i>' : '<i class="fas fa-robot"></i>';

        const contentDiv = document.createElement('div');
        contentDiv.className = 'message-content';

        let messageHTML = '';

        // Add image if present
        if (content.image) {
            messageHTML += `<img src="data:image/jpeg;base64,${content.image}" class="message-image" alt="Uploaded image">`;
        }

        // Add text
        if (content.text) {
            messageHTML += `<div class="message-text">${this.formatMessage(content.text)}</div>`;
        }

        // Add timestamp
        const timeString = this.formatTime(content.timestamp);
        messageHTML += `<div class="message-time">${timeString}</div>`;

        contentDiv.innerHTML = messageHTML;

        messageDiv.appendChild(avatarDiv);
        messageDiv.appendChild(contentDiv);

        this.elements.chatContainer.appendChild(messageDiv);
        this.scrollToBottom();
    }

    formatMessage(text) {
        // Convert URLs to links
        const urlRegex = /(https?:\/\/[^\s]+)/g;
        text = text.replace(urlRegex, '<a href="$1" target="_blank" rel="noopener noreferrer">$1</a>');
        
        // Convert line breaks to <br>
        text = text.replace(/\n/g, '<br>');
        
        return text;
    }

    formatTime(date) {
        return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    }

    scrollToBottom() {
        this.elements.chatContainer.scrollTop = this.elements.chatContainer.scrollHeight;
    }

    showLoading() {
        this.elements.loadingOverlay.style.display = 'flex';
    }

    hideLoading() {
        this.elements.loadingOverlay.style.display = 'none';
    }

    showError(message) {
        this.elements.errorMessage.textContent = message;
        this.elements.errorToast.style.display = 'flex';
        
        // Auto hide after 5 seconds
        setTimeout(() => {
            this.hideError();
        }, 5000);
    }

    hideError() {
        this.elements.errorToast.style.display = 'none';
    }

    showToast(message, type = 'info') {
        // Simple toast notification (could be enhanced)
        console.log(`${type.toUpperCase()}: ${message}`);
    }
}

// Initialize the chat when the page loads
document.addEventListener('DOMContentLoaded', () => {
    new RadiologyChat();
});

// Service Worker Registration for PWA capabilities (optional)
if ('serviceWorker' in navigator) {
    window.addEventListener('load', () => {
        navigator.serviceWorker.register('/sw.js')
            .then((registration) => {
                console.log('SW registered: ', registration);
            })
            .catch((registrationError) => {
                console.log('SW registration failed: ', registrationError);
            });
    });
}
