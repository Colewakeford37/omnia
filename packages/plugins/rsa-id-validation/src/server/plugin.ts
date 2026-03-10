/**
 * RSA ID Validation Plugin for NocoBase
 * 
 * Validates South African ID numbers according to the official format:
 * - 13 digits total (YYMMDDSSSSCAZ)
 * - YYMMDD = Date of birth
 * - SSSS = Sequential number (0000-4999 = female, 5000-9999 = male)
 * - C = Citizenship (0=SA citizen, 1=permanent resident)
 * - A = Race (previously used, now typically 8)
 * - Z = Luhn checksum digit
 */

import { Plugin } from '@nocobase/server';
import { Database } from '@nocobase/database';

export class RSAIDValidationPlugin extends Plugin {
  async load() {
    const db = this.app.db as Database;
    
    // Add RSA ID validation field to customers collection
    this.addRSAIDValidation(db);
    
    // Add API endpoint for RSA ID validation
    this.addValidationEndpoint();
    
    // Add FICA status calculation
    this.addFICAStatusCalculation(db);
  }

  private addRSAIDValidation(db: Database) {
    // Extend the customers collection with RSA ID validation
    db.collection({
      name: 'customers',
      fields: [
        {
          name: 'rsa_id_number',
          type: 'string',
          title: 'RSA ID Number',
          unique: true,
          validation: {
            validator: this.validateRSAID.bind(this),
            message: 'Invalid RSA ID number format'
          },
          uiSchema: {
            'x-component-props': {
              placeholder: 'Enter 13-digit RSA ID number',
              maxLength: 13
            }
          }
        },
        {
          name: 'date_of_birth',
          type: 'date',
          title: 'Date of Birth',
          // Auto-populate from RSA ID
          uiSchema: {
            'x-read-pretty': true
          }
        },
        {
          name: 'gender',
          type: 'string',
          title: 'Gender',
          // Auto-populate from RSA ID
          uiSchema: {
            'x-read-pretty': true,
            enum: [
              { label: 'Male', value: 'male' },
              { label: 'Female', value: 'female' }
            ]
          }
        },
        {
          name: 'citizenship',
          type: 'string',
          title: 'Citizenship Status',
          // Auto-populate from RSA ID
          uiSchema: {
            'x-read-pretty': true,
            enum: [
              { label: 'South African Citizen', value: 'citizen' },
              { label: 'Permanent Resident', value: 'resident' }
            ]
          }
        },
        {
          name: 'rsa_id_valid',
          type: 'boolean',
          title: 'RSA ID Valid',
          defaultValue: false,
          uiSchema: {
            'x-read-pretty': true,
            'x-component-props': {
              checkedChildren: 'Valid',
              unCheckedChildren: 'Invalid'
            }
          }
        }
      ]
    });
  }

  private validateRSAID(rsaId: string): boolean {
    if (!rsaId || rsaId.length !== 13 || !/^\d{13}$/.test(rsaId)) {
      return false;
    }

    try {
      // Extract components
      const year = parseInt(rsaId.substring(0, 2));
      const month = parseInt(rsaId.substring(2, 4));
      const day = parseInt(rsaId.substring(4, 6));
      const sequential = parseInt(rsaId.substring(6, 10));
      const citizenship = parseInt(rsaId.substring(10, 11));
      const checksum = parseInt(rsaId.substring(12, 13));

      // Validate date components
      if (month < 1 || month > 12) return false;
      if (day < 1 || day > 31) return false;

      // Validate sequential number (gender)
      if (sequential < 0 || sequential > 9999) return false;

      // Validate citizenship
      if (citizenship < 0 || citizenship > 1) return false;

      // Validate Luhn checksum
      return this.validateLuhnChecksum(rsaId);

    } catch (error) {
      return false;
    }
  }

  private validateLuhnChecksum(rsaId: string): boolean {
    let sum = 0;
    let alternate = false;

    // Process from right to left
    for (let i = rsaId.length - 1; i >= 0; i--) {
      let n = parseInt(rsaId.charAt(i));

      if (alternate) {
        n *= 2;
        if (n > 9) {
          n = (n % 10) + 1;
        }
      }

      sum += n;
      alternate = !alternate;
    }

    return (sum % 10) === 0;
  }

  private extractRSAIDInfo(rsaId: string): any {
    if (!this.validateRSAID(rsaId)) {
      return null;
    }

    const year = parseInt(rsaId.substring(0, 2));
    const month = parseInt(rsaId.substring(2, 4));
    const day = parseInt(rsaId.substring(4, 6));
    const sequential = parseInt(rsaId.substring(6, 10));
    const citizenship = parseInt(rsaId.substring(10, 11));

    // Determine full year (assuming 00-49 = 2000s, 50-99 = 1900s)
    const fullYear = year < 50 ? 2000 + year : 1900 + year;

    return {
      dateOfBirth: new Date(fullYear, month - 1, day),
      gender: sequential < 5000 ? 'female' : 'male',
      citizenship: citizenship === 0 ? 'citizen' : 'resident',
      age: this.calculateAge(new Date(fullYear, month - 1, day))
    };
  }

  private calculateAge(dateOfBirth: Date): number {
    const today = new Date();
    let age = today.getFullYear() - dateOfBirth.getFullYear();
    const monthDiff = today.getMonth() - dateOfBirth.getMonth();
    
    if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < dateOfBirth.getDate())) {
      age--;
    }
    
    return age;
  }

  private addValidationEndpoint() {
    // Add API endpoint for RSA ID validation
    this.app.resource({
      name: 'rsa-validation',
      actions: {
        validate: async (ctx) => {
          const { rsaId } = ctx.request.body;
          
          if (!rsaId) {
            ctx.throw(400, 'RSA ID number is required');
          }

          const isValid = this.validateRSAID(rsaId);
          const info = isValid ? this.extractRSAIDInfo(rsaId) : null;

          ctx.body = {
            valid: isValid,
            info: info,
            message: isValid ? 'Valid RSA ID number' : 'Invalid RSA ID number format'
          };
        }
      }
    });
  }

  private addFICAStatusCalculation(db: Database) {
    // Add hook to auto-calculate FICA status when customer data changes
    db.on('customers.afterCreate', async (model, options) => {
      await this.updateFICAStatus(model.id, db);
    });

    db.on('customers.afterUpdate', async (model, options) => {
      await this.updateFICAStatus(model.id, db);
    });

    // Add hook to check document expiry
    db.on('fica_documents.afterUpdate', async (model, options) => {
      if (model.verified) {
        await this.updateFICAStatus(model.customer_id, db);
      }
    });
  }

  private async updateFICAStatus(customerId: string, db: Database) {
    try {
      const customerRepo = db.getRepository('customers');
      const documentRepo = db.getRepository('fica_documents');

      const customer = await customerRepo.findById(customerId);
      const documents = await documentRepo.find({
        filter: {
          customer_id: customerId,
          verified: true
        }
      });

      // Check if all required documents are present and valid
      const requiredDocuments = ['rsa_id', 'proof_of_address'];
      const hasAllRequiredDocs = requiredDocuments.every(docType => 
        documents.some(doc => doc.document_type === docType)
      );

      // Check if any documents are expired
      const today = new Date();
      const hasExpiredDocs = documents.some(doc => 
        doc.expiry_date && new Date(doc.expiry_date) < today
      );

      // Check if RSA ID is valid
      const hasValidRSAId = customer.rsa_id_number && this.validateRSAID(customer.rsa_id_number);

      // Update FICA compliance status
      const ficaCompliant = hasValidRSAId && hasAllRequiredDocs && !hasExpiredDocs;
      
      await customerRepo.update({
        filterByTk: customerId,
        values: {
          fica_compliant: ficaCompliant,
          fica_expiry: hasExpiredDocs ? today : null,
          rsa_id_valid: hasValidRSAId
        }
      });

    } catch (error) {
      console.error('Error updating FICA status:', error);
    }
  }
}

export default RSAIDValidationPlugin;