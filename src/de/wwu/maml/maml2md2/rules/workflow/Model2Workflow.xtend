package de.wwu.maml.maml2md2.rules.workflow

import org.eclipse.emf.ecore.resource.Resource
import de.wwu.md2.framework.mD2.PackageDefinition
import de.wwu.maml.maml2md2.rules.Elem2Elem
import de.wwu.maml.maml2md2.rules.Maml2md2Transformation

class Model2Workflow extends Elem2Elem {
	
	public static final String ruleID = "Model->MD2Model[Workflow]"
	
	new(Resource src, Resource trgt, Resource corr) {
		super(src, trgt, corr)
		
	}
	
	override def sourceToTarget() {
		sourceModel.allContents.filter(typeof(de.wwu.maml.dsl.maml.Model))
			.forEach[m |
				// Create workflow
				val corrW = m.getOrCreateCorrModelElement("MD2Model.Workflow")
				val targetW = corrW.getOrCreateTargetElem(targetPackage.MD2Model) as de.wwu.md2.framework.mD2.MD2Model
				
				val targetPackageWorkflow = createTargetElement(targetPackage.packageDefinition) as PackageDefinition
				targetPackageWorkflow.pkgName = Maml2md2Transformation.PACKAGE_NAME + ".workflows"
				targetW.package = targetPackageWorkflow
				
				val targetWorkflowLayer = createTargetElement(targetPackage.workflow) as de.wwu.md2.framework.mD2.Workflow
				targetW.modelLayer = targetWorkflowLayer
				targetModel.contents += targetW
			]
	}
	
	override def targetToSource() {
		targetModel.allContents.filter(typeof(de.wwu.md2.framework.mD2.Model))
			.forEach[m |
				val corr = m.getOrCreateCorrModelElement(ruleID)
				val source = corr.getOrCreateSourceElem(sourcePackage.model)
				sourceModel.contents += source
			]
	}
	
}