/**
 * Supabase Storage Service
 * Handles file uploads to Supabase Storage instead of local filesystem
 * 
 * Setup:
 * 1. Get your Supabase URL and anon key from Supabase dashboard
 * 2. Set SUPABASE_URL and SUPABASE_ANON_KEY environment variables
 * 3. Create a 'avatars' bucket in Supabase Storage (Settings → Storage)
 * 4. Set bucket to public if you want direct access, or use signed URLs
 */

const { createClient } = require('@supabase/supabase-js');
const fs = require('fs');
const path = require('path');

// Initialize Supabase client (only if credentials are provided)
let supabase = null;
if (process.env.SUPABASE_URL && process.env.SUPABASE_ANON_KEY) {
  supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_ANON_KEY
  );
}

class StorageService {
  /**
   * Upload a file to Supabase Storage
   * @param {Buffer|string} file - File buffer or file path
   * @param {string} bucket - Storage bucket name (default: 'avatars')
   * @param {string} fileName - Name for the file in storage
   * @param {string} contentType - MIME type (e.g., 'image/jpeg')
   * @returns {Promise<string>} Public URL of the uploaded file
   */
  static async uploadFile(file, bucket = 'avatars', fileName, contentType) {
    // If Supabase is not configured, fall back to local storage
    if (!supabase) {
      console.warn('⚠️  Supabase Storage not configured. Using local storage fallback.');
      return this._uploadLocal(file, fileName);
    }

    try {
      // If file is a path, read it as buffer
      let fileBuffer;
      if (typeof file === 'string') {
        fileBuffer = fs.readFileSync(file);
      } else {
        fileBuffer = file;
      }

      // Upload to Supabase Storage
      const { data, error } = await supabase.storage
        .from(bucket)
        .upload(fileName, fileBuffer, {
          contentType: contentType,
          upsert: true, // Replace if exists
        });

      if (error) {
        console.error('Supabase upload error:', error);
        // Fall back to local storage
        return this._uploadLocal(file, fileName);
      }

      // Get public URL
      const { data: urlData } = supabase.storage
        .from(bucket)
        .getPublicUrl(fileName);

      return urlData.publicUrl;
    } catch (error) {
      console.error('Storage upload error:', error);
      // Fall back to local storage
      return this._uploadLocal(file, fileName);
    }
  }

  /**
   * Delete a file from Supabase Storage
   * @param {string} bucket - Storage bucket name
   * @param {string} fileName - Name of the file to delete
   * @returns {Promise<boolean>} Success status
   */
  static async deleteFile(bucket, fileName) {
    if (!supabase) {
      // Try to delete locally
      return this._deleteLocal(fileName);
    }

    try {
      const { error } = await supabase.storage
        .from(bucket)
        .remove([fileName]);

      if (error) {
        console.error('Supabase delete error:', error);
        // Try local delete as fallback
        return this._deleteLocal(fileName);
      }

      return true;
    } catch (error) {
      console.error('Storage delete error:', error);
      return this._deleteLocal(fileName);
    }
  }

  /**
   * Extract file path from URL (for backward compatibility)
   * @param {string} url - Full URL or local path
   * @returns {string} File name
   */
  static extractFileName(url) {
    if (!url) return null;
    
    // If it's a Supabase URL, extract the file name
    if (url.includes('supabase.co/storage')) {
      const parts = url.split('/');
      return parts[parts.length - 1];
    }
    
    // If it's a local path, extract filename
    if (url.startsWith('/uploads')) {
      return path.basename(url);
    }
    
    return url;
  }

  /**
   * Fallback: Upload to local filesystem
   * @private
   */
  static _uploadLocal(file, fileName) {
    const uploadDir = path.join(__dirname, '../uploads/avatars');
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }

    const filePath = path.join(uploadDir, fileName);
    
    // If file is a path, copy it; otherwise write buffer
    if (typeof file === 'string') {
      fs.copyFileSync(file, filePath);
    } else {
      fs.writeFileSync(filePath, file);
    }

    return `/uploads/avatars/${fileName}`;
  }

  /**
   * Fallback: Delete from local filesystem
   * @private
   */
  static _deleteLocal(fileName) {
    try {
      const filePath = path.join(__dirname, '../uploads/avatars', fileName);
      if (fs.existsSync(filePath)) {
        fs.unlinkSync(filePath);
        return true;
      }
    } catch (error) {
      console.error('Local delete error:', error);
    }
    return false;
  }
}

module.exports = StorageService;

