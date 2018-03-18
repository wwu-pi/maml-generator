package de.wwu.maml.maml2md2.rules.model

import de.wwu.maml.dsl.mamldata.Boolean
import de.wwu.maml.dsl.mamldata.Collection
import de.wwu.maml.dsl.mamldata.CustomType
import de.wwu.maml.dsl.mamldata.DataType
import de.wwu.maml.dsl.mamldata.Date
import de.wwu.maml.dsl.mamldata.DateTime
import de.wwu.maml.dsl.mamldata.Email
import de.wwu.maml.dsl.mamldata.Enum
import de.wwu.maml.dsl.mamldata.File
import de.wwu.maml.dsl.mamldata.Float
import de.wwu.maml.dsl.mamldata.Image
import de.wwu.maml.dsl.mamldata.Integer
import de.wwu.maml.dsl.mamldata.Location
import de.wwu.maml.dsl.mamldata.PhoneNumber
import de.wwu.maml.dsl.mamldata.Time
import de.wwu.maml.dsl.mamldata.Url
import de.wwu.maml.maml2md2.rules.Elem2Elem
import de.wwu.md2.framework.mD2.Attribute
import de.wwu.md2.framework.mD2.AttributeType
import de.wwu.md2.framework.mD2.BooleanType
import de.wwu.md2.framework.mD2.DateTimeType
import de.wwu.md2.framework.mD2.DateType
import de.wwu.md2.framework.mD2.Entity
import de.wwu.md2.framework.mD2.EnumBody
import de.wwu.md2.framework.mD2.FloatType
import de.wwu.md2.framework.mD2.IntegerType
import de.wwu.md2.framework.mD2.Model
import de.wwu.md2.framework.mD2.ModelElement
import de.wwu.md2.framework.mD2.ReferencedType
import de.wwu.md2.framework.mD2.StringType
import de.wwu.md2.framework.mD2.TimeType
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.ResourceSet

import static extension de.wwu.maml.maml2md2.util.ResourceHelper.*
import de.wwu.md2.framework.mD2.FileType

class DataType2ModelElement extends Elem2Elem {
	
	public static final String ruleID = "DataType->ModelElement"
	public static final String ruleIDProperty = "Property->Attribute"
	
	new(ResourceSet src, ResourceSet trgt, Resource corr) {
		super(src, trgt, corr)
	}
	
	override def sourceToTarget() {
		// Enum
		sourceModel.allContents.filter(typeof(Enum))
			.forEach[src |
				// Create element and its content
				val corr = src.getOrCreateCorrModelElement(ruleID)
				val enum = corr.getOrCreateTargetElem(targetPackage.enum) as de.wwu.md2.framework.mD2.Enum
				enum.name = src.name
				enum.enumBody = createTargetElement(targetPackage.enumBody) as EnumBody
				val values = enum.enumBody.elements
				for(value : src.values){
					values.add(value.value)
				}
				
				// Attach to container 
				val container = resolveElement(targetPackage.model, Model2Model.ruleID)
				(container as Model)?.modelElements.add(enum)
				
				targetModel.getMD2ModelResource.contents += enum
			]
			
		// Entity needs two steps: first create all target types empty, then process attributes (to avoid missing references) 
		sourceModel.allContents.filter(typeof(CustomType))
			.forEach[src |
				// Create element
				val corr = src.getOrCreateCorrModelElement(ruleID)
				val entity = corr.getOrCreateTargetElem(targetPackage.entity) as Entity
				entity.name = src.name.toFirstUpper
		]
		
		sourceModel.allContents.filter(typeof(CustomType))
			.forEach[src |
				val corr = src.getOrCreateCorrModelElement(ruleID)
				val entity = corr.targetElement as Entity
				
				// Process contained attributes
				val values = entity.attributes
				for(property : src.attributes){
					val attrCorr = property.getOrCreateCorrModelElement(ruleIDProperty)
					val attr = attrCorr.getOrCreateTargetElem(targetPackage.attribute) as Attribute
					attr.name = property.name.toFirstLower
					attr.type = MAMLDataTypeToMD2AttributeType(property.type)
					attr.extendedName = null; // Not explicitly modelled in MAML
					attr.description = null; // Not explicitly modelled in MAML
					
					values.add(attr)
					targetModel.getMD2ModelResource.contents += attr
				}
				
				// Attach to container 
				val container = resolveElement(targetPackage.model, Model2Model.ruleID)
				(container as Model)?.modelElements.add(entity)
				
				targetModel.getMD2ModelResource.contents += entity
			]
	}
	
	override def targetToSource() {
//		targetModel.allContents.filter(typeof(de.wwu.md2.framework.mD2.Model))
//			.forEach[m |
//				val corr = m.getOrCreateCorrModelElement(ruleID)
//				val source = corr.findOrCreateSourceElemOfType(sourcePackage.model)
//				sourceModel.MAMLResource.contents += source
//			]
	}
	
	def AttributeType MAMLDataTypeToMD2AttributeType(DataType mamlType){
		switch mamlType {
			// PrimitiveTypes
			// TODO handle params
			Location: {
				// TODO
				return null
			}
			PhoneNumber,
			Url,
			Email,
			de.wwu.maml.dsl.mamldata.String: {
				return createTargetElement(targetPackage.stringType) as StringType
			}
			Boolean: {
				return createTargetElement(targetPackage.booleanType) as BooleanType
			}
			Integer: {
				return createTargetElement(targetPackage.integerType) as IntegerType
			}
			Float: {
				return createTargetElement(targetPackage.floatType) as FloatType
			}
			DateTime: {
				return createTargetElement(targetPackage.dateTimeType) as DateTimeType
			}
			Date: {
				return createTargetElement(targetPackage.dateType) as DateType
			}
			Time: {
				return createTargetElement(targetPackage.timeType) as TimeType
			}
			Image,
			File: {
				return createTargetElement(targetPackage.fileType) as FileType
			}
			Collection: {
				val type = MAMLDataTypeToMD2AttributeType(mamlType.type)
				type.many = true
				return type
			}
			CustomType: {
				val type = createTargetElement(targetPackage.referencedType) as ReferencedType
				type.element = mamlType.getOrCreateCorrModelElement(ruleID).targetElement as ModelElement
				return type
			}
		}
	}
	
}